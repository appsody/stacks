package application.wm;

public Class IdentityProvider {
    public Identity getIdentity(string id) {
        Wallet wallet = WalletManager.getWallet();
        return wallet.getIdentity(id);
    }
}