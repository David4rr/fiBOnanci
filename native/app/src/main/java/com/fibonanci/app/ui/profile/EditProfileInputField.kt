package com.fibonanci.app.ui.profile

import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors

private val errorRed = Color(0xFFEF4444)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileInputField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    hintText: String,
    prefixIcon: ImageVector,
    keyboardType: KeyboardType = KeyboardType.Text,
    maxLines: Int = 1,
    errorText: String? = null,
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isError = errorText != null
    val shape = RoundedCornerShape(14.dp)
    val colors = OutlinedTextFieldDefaults.colors(
        focusedContainerColor = AppColors.canvasInputSearch,
        unfocusedContainerColor = AppColors.canvasInputSearch,
        errorContainerColor = AppColors.canvasInputSearch,
        focusedBorderColor = AppColors.neoChartreuse,
        unfocusedBorderColor = AppColors.canvasBorder,
        errorBorderColor = errorRed,
        cursorColor = AppColors.neoChartreuse,
        errorCursorColor = errorRed,
        focusedLeadingIconColor = AppColors.textMuted,
        unfocusedLeadingIconColor = AppColors.textMuted,
        errorLeadingIconColor = AppColors.textMuted,
    )
    Column(Modifier.fillMaxWidth()) {
        Text(label, style = jakarta(12.5.sp, FontWeight.SemiBold, AppColors.textWhite))
        Spacer(Modifier.height(6.dp))
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier.fillMaxWidth(),
            textStyle = TextStyle(color = AppColors.textWhite, fontSize = 13.5.sp),
            cursorBrush = SolidColor(if (isError) errorRed else AppColors.neoChartreuse),
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
            singleLine = maxLines == 1,
            maxLines = maxLines,
            minLines = 1,
            interactionSource = interactionSource,
            decorationBox = { innerTextField ->
                OutlinedTextFieldDefaults.DecorationBox(
                    value = value,
                    innerTextField = innerTextField,
                    enabled = true,
                    singleLine = maxLines == 1,
                    visualTransformation = VisualTransformation.None,
                    interactionSource = interactionSource,
                    isError = isError,
                    placeholder = { Text(hintText, style = TextStyle(color = AppColors.textSubtle, fontSize = 13.sp)) },
                    leadingIcon = { Icon(prefixIcon, contentDescription = null, modifier = Modifier.size(18.dp)) },
                    colors = colors,
                    contentPadding = PaddingValues(horizontal = 14.dp, vertical = 12.dp),
                    container = {
                        OutlinedTextFieldDefaults.Container(
                            enabled = true,
                            isError = isError,
                            interactionSource = interactionSource,
                            colors = colors,
                            shape = shape,
                            focusedBorderThickness = 1.5.dp,
                            unfocusedBorderThickness = 1.dp,
                        )
                    },
                )
            },
        )
        if (errorText != null) {
            Text(
                errorText,
                style = TextStyle(color = errorRed, fontSize = 12.sp),
                modifier = Modifier.padding(start = 12.dp, top = 6.dp),
            )
        }
    }
}
