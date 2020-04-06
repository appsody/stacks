package application.wm;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;

import org.hyperledger.fabric.gateway.Wallet;


public class FileSystemWallet implements WalletManager {
    static final String WALLET_PATH_ENV_VAR="WALLET_PATH";

    public Wallet getWallet() {
        String walletPath = System.getenv().get(WALLET_PATH_ENV_VAR);

        Wallet wallet;
        try {
            Path basePath = FileSystems.getDefault().getPath(walletPath);
            wallet = Wallet.createFileSystemWallet(basePath);
            return wallet;
        } catch (IOException excpt) {
            return null;
        }

    }
}