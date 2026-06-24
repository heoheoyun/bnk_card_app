import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ApplicationStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const ApplicationStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final step     = i + 1;
          final isActive = step == currentStep;
          final isDone   = step < currentStep;

          return Expanded(
            child: Row(
              children: [
                // 원형 스텝 번호
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isDone
                        ? AppColors.teal600
                        : AppColors.gray200,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                      '$step',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : AppColors.gray400,
                      ),
                    ),
                  ),
                ),
                // 연결선 (마지막 스텝 제외)
                if (step < totalSteps)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone
                          ? AppColors.teal600
                          : AppColors.gray200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}