package com.fibonanci.app.ui.wallet

import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.FinanceViewModel
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.theme.AppColors

object WalletDeleteDialog {
    // dismissModal == Navigator.pop(modalContext)
    fun executeDelete(host: ModalHost, vm: FinanceViewModel, dismissModal: () -> Unit, wallet: WalletEntry) {
        vm.deleteWallet(wallet.id)
        dismissModal()
        host.showSnackBar(
            message = "Rekening ${wallet.name} berhasil dihapus.",
            background = AppColors.neoCoral,
            contentColor = AppColors.textDarkPrimary,
        )
    }

    fun show(host: ModalHost, vm: FinanceViewModel, dismissModal: () -> Unit, wallet: WalletEntry) {
        executeDelete(host, vm, dismissModal, wallet)
    }
}
