import 'package:flutter/material.dart';
import '../../core/constants/brand_colors.dart';
import '../../core/constants/theme.dart';

/// Premium card widget following Thingual brand guidelines
class ThingualCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool enableHover;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;

  const ThingualCard({
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.enableHover = true,
    this.border,
    this.shadows,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color:
          backgroundColor ??
          (isDark ? ThingualColors.darkSurface : Colors.white),
      borderRadius: BorderRadius.circular(ThingualRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThingualRadius.lg),
        child: Container(
          padding: padding ?? const EdgeInsets.all(ThingualSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThingualRadius.lg),
            border:
                border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.grey[200]!,
                ),
            boxShadow:
                shadows ??
                [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Premium button widget
class ThingualButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final bool isOutlined;
  final Size? size;

  const ThingualButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.isOutlined = false,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? Size.fromHeight(50);

    if (isOutlined) {
      return SizedBox(
        width: buttonSize.width == double.maxFinite ? buttonSize.width : null,
        height: buttonSize.height,
        child: OutlinedButton.icon(
          onPressed: isLoading || !isEnabled ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : Icon(icon ?? Icons.check),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: buttonSize.width == double.maxFinite ? buttonSize.width : null,
      height: buttonSize.height,
      child: ElevatedButton.icon(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon ?? Icons.arrow_forward),
        label: Text(label),
      ),
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeMore;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeMore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThingualSpacing.lg,
        vertical: ThingualSpacing.md,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: ThingualSpacing.xs),
                  child: Text(
                    subtitle!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
          if (onSeeMore != null) ...[
            const Spacer(),
            TextButton(
              onPressed: onSeeMore,
              child: Text(
                'See more',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ThingualColors.deepIndigo,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Greeting card widget
class GreetingCard extends StatelessWidget {
  final String greeting;
  final String userName;

  const GreetingCard({
    required this.greeting,
    required this.userName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThingualSpacing.xl),
      decoration: BoxDecoration(
        gradient: ThingualColors.primaryGradient,
        borderRadius: BorderRadius.circular(ThingualRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: ThingualSpacing.sm),
          Text(
            'Welcome back, $userName! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats card widget
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData? icon;
  final Color? accentColor;

  const StatsCard({
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
    this.accentColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ThingualCard(
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(ThingualSpacing.md),
              decoration: BoxDecoration(
                color: (accentColor ?? ThingualColors.deepIndigo).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(ThingualRadius.md),
              ),
              child: Icon(
                icon,
                color: accentColor ?? ThingualColors.deepIndigo,
                size: 20,
              ),
            ),
          const SizedBox(height: ThingualSpacing.md),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? ThingualColors.dimText : Colors.grey[600],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xs),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextSpan(
                  text: ' $unit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? ThingualColors.dimText : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared 2-column grid for tile cards (Stats, etc.)
class ThingualTileGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double? childAspectRatio;

  const ThingualTileGrid({
    required this.children,
    this.spacing = ThingualSpacing.lg,
    this.childAspectRatio,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    // Lower aspect ratio => taller tiles => less chance of vertical overflow.
    final effectiveRatio = childAspectRatio ?? (isNarrow ? 1.25 : 1.65);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: effectiveRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Thingual progress bar widget
class ThingualProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;

  const ThingualProgressBar({
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 6,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(ThingualRadius.full),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: height,
        backgroundColor:
            backgroundColor ??
            (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]),
        valueColor: AlwaysStoppedAnimation(color ?? ThingualColors.deepIndigo),
      ),
    );
  }
}

/// Badge widget
class ThingualBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ThingualBadge({
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThingualSpacing.md,
        vertical: ThingualSpacing.xs,
      ),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? ThingualColors.deepIndigo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThingualRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? ThingualColors.deepIndigo),
            const SizedBox(width: ThingualSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor ?? ThingualColors.deepIndigo,
            ),
          ),
        ],
      ),
    );
  }
}
