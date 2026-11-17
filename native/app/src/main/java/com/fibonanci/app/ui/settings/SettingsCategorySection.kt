package com.fibonanci.app.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.PlusJakartaSans

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun SettingsCategorySection(categories: List<CategoryEntry>) {
    val vm = LocalFinance.current
    var selectedType by rememberSaveable { mutableStateOf("expense") }
    var isAdding by rememberSaveable { mutableStateOf(false) }
    var selectedColor by rememberSaveable { mutableStateOf(CategoryColorPicker.palette.first()) }
    var nameCtrl by rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(TextFieldValue("")) }

    fun submitCategory() {
        val name = nameCtrl.text.trim()
        if (name.isEmpty()) return
        vm.addCategory(name = name, type = selectedType, colorHex = selectedColor)
        nameCtrl = TextFieldValue("")
        isAdding = false
    }

    val allActive = categories.filter { !it.isDeleted }
    val filtered = allActive.filter { it.type == selectedType }

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 48.dp)) {
        item {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Row {
                    SettingsStyle.flatChip(
                        key = "settings_cat_type_expense", label = "Pengeluaran",
                        selected = selectedType == "expense", onTap = { selectedType = "expense" },
                    )
                    Spacer(Modifier.width(8.dp))
                    SettingsStyle.flatChip(
                        key = "settings_cat_type_income", label = "Pemasukan",
                        selected = selectedType == "income", onTap = { selectedType = "income" },
                    )
                }
                Text(
                    if (isAdding) "Batal" else "+ Tambah", style = SettingsStyle.accent,
                    modifier = Modifier.testTag("settings_add_category_toggle").plainClickable { isAdding = !isAdding },
                )
            }
        }
        item { Spacer(Modifier.height(16.dp)) }
        if (isAdding) {
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    SettingsUnderlineField(
                        value = nameCtrl, onValueChange = { nameCtrl = it }, textStyle = SettingsStyle.title,
                        hintText = "Nama kategori baru...", hintStyle = SettingsStyle.sub,
                        modifier = Modifier.weight(1f).testTag("settings_new_category_input"),
                    )
                    Spacer(Modifier.width(12.dp))
                    Text(
                        "Simpan", style = SettingsStyle.accent,
                        modifier = Modifier.testTag("settings_save_category_button").plainClickable { submitCategory() },
                    )
                }
            }
            item { Spacer(Modifier.height(12.dp)) }
            item { CategoryColorPicker(selectedColor = selectedColor, onColorChanged = { selectedColor = it }) }
            item { Spacer(Modifier.height(16.dp)) }
        }
        item {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                for (cat in filtered) {
                    Row(
                        Modifier
                            .background(Color.White.copy(alpha = 0.03f), RoundedCornerShape(8.dp))
                            .padding(horizontal = 10.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Box(Modifier.size(6.dp).background(CategoryColorPicker.parseColor(cat.colorHex), CircleShape))
                        Spacer(Modifier.width(7.dp))
                        Text(
                            cat.name,
                            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, fontWeight = FontWeight.W500, color = Color.White.copy(alpha = 0.85f)),
                        )
                        if (filtered.size > 1) {
                            Spacer(Modifier.width(6.dp))
                            Icon(
                                Icons.Rounded.Close, contentDescription = null, tint = Color.White.copy(alpha = 0.38f),
                                modifier = Modifier
                                    .testTag("settings_delete_cat_${cat.id}")
                                    .plainClickable { vm.deleteCategory(cat.id) }
                                    .size(13.dp),
                            )
                        }
                    }
                }
            }
        }
    }
}
