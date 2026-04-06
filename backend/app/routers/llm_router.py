"""
API endpoints for LLM-based assessment
"""

import logging
from typing import Optional
from pydantic import BaseModel
from fastapi import APIRouter, HTTPException

from app.services.llm_service import get_llm_service

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/llm", tags=["llm"])


class EvaluateDescriptionRequest(BaseModel):
    """Request for picture description evaluation"""

    user_response: str
    keywords: list[str]
    reference_description: str
    image_context: Optional[str] = None


class ScoreBreakdown(BaseModel):
    """Score breakdown by component"""

    grammar: int
    vocabulary: int
    accuracy: int
    detail: int


class EvaluationResult(BaseModel):
    """LLM evaluation result"""

    score: float
    cefr_level: str
    breakdown: ScoreBreakdown
    feedback: str


@router.post("/evaluate", response_model=EvaluationResult)
async def evaluate_description(request: EvaluateDescriptionRequest):
    """
    Evaluate a picture description using LLM

    Returns:
        LLM evaluation result with score, CEFR level, and feedback
    """
    try:
        logger.info("[LLM API] Received evaluation request")
        logger.info(f"[LLM API] User response length: {len(request.user_response)}")
        logger.info(f"[LLM API] Keywords: {len(request.keywords)}")

        llm_service = get_llm_service()

        # Initialize model if needed
        if not llm_service.is_initialized():
            logger.info("[LLM API] Model not initialized, attempting initialization...")
            if not llm_service.initialize():
                raise HTTPException(
                    status_code=503,
                    detail="LLM model not available. Please download the model first.",
                )

        # Run evaluation
        result = llm_service.evaluate_description(
            user_response=request.user_response,
            keywords=request.keywords,
            reference_description=request.reference_description,
        )

        if result is None:
            raise HTTPException(
                status_code=500, detail="LLM evaluation failed. Please try again."
            )

        logger.info("[LLM API] Evaluation completed successfully")
        return EvaluationResult(
            score=result["score"],
            cefr_level=result["cefr_level"],
            breakdown=ScoreBreakdown(**result["breakdown"]),
            feedback=result["feedback"],
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[LLM API] Evaluation error: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=500, detail=f"Evaluation failed: {str(e)}"
        ) from e


@router.get("/status")
async def llm_status():
    """Check if LLM is initialized and ready"""
    try:
        llm_service = get_llm_service()
        return {
            "initialized": llm_service.is_initialized(),
            "model_path": llm_service.model_path,
            "ready": llm_service.is_initialized(),
        }
    except Exception as e:
        logger.error(f"[LLM API] Status check failed: {e}")
        return {
            "initialized": False,
            "error": str(e),
            "ready": False,
        }
