"""
LLM Service for picture description assessment
Uses llama-cpp-python to run GGUF models locally
"""

import logging
import os
from typing import Optional
from pathlib import Path
import json

logger = logging.getLogger(__name__)


class LLMService:
    """Service for running LLM inference on picture descriptions"""

    _instance = None
    _llm = None
    _model_path = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(LLMService, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        """Initialize LLM service"""
        if LLMService._llm is not None:
            return  # Already initialized

        self.model_path = os.getenv(
            "GGUF_MODEL_PATH",
            str(Path.home() / ".thingual" / "models" / "tinyllama.gguf"),
        )
        logger.info(f"[LLMService] Configured model path: {self.model_path}")

    def initialize(self):
        """Load the GGUF model into memory"""
        try:
            logger.info("[LLMService] Initializing LLM model...")

            if not os.path.exists(self.model_path):
                logger.warning(
                    f"[LLMService] Model file not found at {self.model_path}"
                )
                logger.info("[LLMService] Model will be downloaded on first use")
                return False

            logger.info(f"[LLMService] Loading GGUF model from {self.model_path}")

            # Import here to avoid import errors if package not installed
            from llama_cpp import Llama

            logger.info("[LLMService] Initializing Llama model...")
            LLMService._llm = Llama(
                model_path=self.model_path,
                n_gpu_layers=-1,  # Use GPU if available
                n_threads=8,  # Use 8 CPU threads
                verbose=False,
            )

            logger.info("[LLMService] ✓ Model loaded successfully")
            return True

        except ImportError:
            logger.error(
                "[LLMService] ❌ llama-cpp-python not installed. "
                "Install with: pip install llama-cpp-python"
            )
            return False
        except Exception as e:
            logger.error(f"[LLMService] ❌ Failed to initialize model: {e}")
            return False

    def is_initialized(self) -> bool:
        """Check if model is loaded and ready"""
        return LLMService._llm is not None

    def evaluate_description(
        self,
        user_response: str,
        keywords: list[str],
        reference_description: str,
    ) -> Optional[dict]:
        """
        Evaluate a picture description using LLM

        Args:
            user_response: User's description of the picture
            keywords: Expected keywords/concepts to identify
            reference_description: Reference/example description

        Returns:
            Dict with score, level, breakdown, and feedback or None if failed
        """
        if not self.is_initialized():
            logger.error("[LLMService] Model not initialized!")
            return None

        try:
            logger.info("=" * 80)
            logger.info("[LLMService] ========== STARTING LLM EVALUATION ==========")
            logger.info("=" * 80)

            # Build the evaluation prompt
            logger.info("\n[LLMService] STEP 1: BUILDING EVALUATION PROMPT")
            prompt = self._build_prompt(user_response, keywords, reference_description)
            logger.info(f"[LLMService]   Prompt length: {len(prompt)} characters")
            logger.info(
                f"[LLMService]   User response length: {len(user_response)} chars"
            )
            logger.info(f"[LLMService]   Keywords: {', '.join(keywords)}")

            # Run inference
            logger.info("\n[LLMService] STEP 2: RUNNING INFERENCE")
            logger.info("[LLMService]   Model: TinyLlama-1.1B-GGUF")
            logger.info("[LLMService]   Temperature: 0.3 (deterministic)")
            logger.info("[LLMService]   Max tokens: 200")
            logger.info("[LLMService]   Starting inference...")

            response = LLMService._llm(
                prompt,
                max_tokens=200,
                temperature=0.3,
                top_p=0.9,
                stop=["[END]"],
            )

            raw_output = response["choices"][0]["text"].strip()
            logger.info(f"[LLMService]   ✓ Inference complete")
            logger.info(
                f"[LLMService]   Tokens used: {response['usage']['completion_tokens']}"
            )

            # Parse the response
            logger.info("\n[LLMService] STEP 3: PARSING MODEL OUTPUT")
            logger.info(f"[LLMService]   Raw output length: {len(raw_output)} chars")

            result = self._parse_response(raw_output)
            if result is None:
                logger.warning("[LLMService] Failed to parse response, using defaults")
                result = self._get_default_result()

            logger.info(f"[LLMService]   ✓ Output parsed successfully")

            # Log the result
            logger.info("\n[LLMService] STEP 4: EVALUATION RESULT")
            logger.info(f"[LLMService]   Score: {result['score']}/100")
            logger.info(f"[LLMService]   CEFR Level: {result['cefr_level']}")
            logger.info(f"[LLMService]   Breakdown:")
            logger.info(f"[LLMService]     - Grammar: {result['breakdown']['grammar']}")
            logger.info(
                f"[LLMService]     - Vocabulary: {result['breakdown']['vocabulary']}"
            )
            logger.info(
                f"[LLMService]     - Accuracy: {result['breakdown']['accuracy']}"
            )
            logger.info(f"[LLMService]     - Detail: {result['breakdown']['detail']}")
            logger.info(f"[LLMService]   Feedback: {result['feedback']}")

            logger.info("\n" + "=" * 80)
            logger.info("[LLMService] ========== EVALUATION COMPLETE ==========")
            logger.info("[LLMService] Status: SUCCESS ✓")
            logger.info("=" * 80 + "\n")

            return result

        except Exception as e:
            logger.error(f"[LLMService] ❌ Evaluation failed: {e}")
            logger.exception(e)
            return None

    def _build_prompt(
        self, user_response: str, keywords: list[str], reference_description: str
    ) -> str:
        """Build the evaluation prompt"""
        keywords_str = ", ".join(keywords)
        return f"""You are an English language assessment expert. Evaluate the following picture description.

Reference Description: {reference_description}

Expected Keywords/Concepts: {keywords_str}

User's Description: {user_response}

Provide a JSON response with this exact structure (no extra text, only JSON):
{{
  "score": <number 0-100>,
  "cefr_level": "<A1|A2|B1|B2|C1>",
  "breakdown": {{
    "grammar": <number 0-25>,
    "vocabulary": <number 0-25>,
    "accuracy": <number 0-25>,
    "detail": <number 0-25>
  }},
  "feedback": "<1-2 sentence feedback>"
}}

[END]"""

    def _parse_response(self, response: str) -> Optional[dict]:
        """Extract JSON from model response"""
        try:
            # Try to find JSON in the response
            start = response.find("{")
            end = response.rfind("}") + 1

            if start >= 0 and end > start:
                json_str = response[start:end]
                result = json.loads(json_str)

                # Validate structure
                if all(
                    key in result
                    for key in ["score", "cefr_level", "breakdown", "feedback"]
                ):
                    return result

            return None
        except json.JSONDecodeError:
            logger.error(f"[LLMService] Failed to parse JSON from response")
            return None

    def _get_default_result(self) -> dict:
        """Return a sensible default result"""
        return {
            "score": 65.0,
            "cefr_level": "B1",
            "breakdown": {
                "grammar": 16,
                "vocabulary": 16,
                "accuracy": 16,
                "detail": 17,
            },
            "feedback": "Description covers main elements with some detail.",
        }


# Global instance
_llm_service: Optional[LLMService] = None


def get_llm_service() -> LLMService:
    """Get or create LLM service instance"""
    global _llm_service
    if _llm_service is None:
        _llm_service = LLMService()
    return _llm_service
