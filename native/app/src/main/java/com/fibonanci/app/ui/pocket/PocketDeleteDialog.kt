package com.fibonanci.app.ui.pocket

import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.ui.FinanceViewModel
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.theme.AppColors

// dart pops the hosting route; here `dismiss` closes the pocket detail modal.
fun executeDeletePocket(vm: FinanceViewModel, host: ModalHost, pocket: PocketEntry, dismiss: () -> Unit) {
    val hasBalance = pocket.currentAmount > 0
    vm.deletePocket(pocket.id)
    dismiss()
    host.showSnackBar(
        message = if (hasBalance) {
            "Kantong \"${pocket.name}\" dihapus & saldo dikembalikan ke rekening."
        } else {
            "Kantong \"${pocket.name}\" berhasil dihapus."
        },
        background = AppColors.neoCoral,
        contentColor = AppColors.textDarkPrimary,
    )
}

fun showPocketDeleteDialog(vm: FinanceViewModel, host: ModalHost, pocket: PocketEntry, dismiss: () -> Unit) {
    executeDeletePocket(vm, host, pocket, dismiss)
}
