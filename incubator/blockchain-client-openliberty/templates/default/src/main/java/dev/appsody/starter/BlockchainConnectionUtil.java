package dev.appsody.starter;

import static org.assertj.core.api.Assertions.assertThat;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;

import org.hyperledger.fabric.sdk.helper.Config;
import org.json.JSONObject;

/**
 * This file contains functions for the use of your test file.
 * It doesn't require any changes for immediate use.
 */
public class BlockchainConnectionUtil {

    public static String getConnectionProfile() {
        return ConnectionConfiguration.getConnectionProfile();
    }

    // Checks if URL is localhost
    public static boolean isLocalhostURL(String url) {
        String[] localhosts = {"localhost", "127.0.0.1"};
        URI parsedURL = null;
        try {
            parsedURL = new URI(url);
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
        assertThat(parsedURL).isNotNull();
        return Arrays.asList(localhosts).indexOf(parsedURL.getHost()) != -1;
    }

    // Used for determining whether to set SERVICE_DISCOVER_AS_LOCALHOST
    public static boolean hasLocalhostURLs() {
        String data = getConnectionProfile();
        assertThat(data).isNotNull();

        JSONObject obj = null;
        obj = new JSONObject(data);
        assertThat(obj).isNotNull();

        String[] nodeTypes = { "orderers", "peers", "certificateAuthorities" };
        String[] presentTypes = JSONObject.getNames(obj);
        ArrayList<String> urls = new ArrayList<>();
        for (String type : nodeTypes) {
            if (Arrays.asList(presentTypes).contains(type)) {
                JSONObject typeObj = obj.getJSONObject(type);
                for (Iterator<String> nodes = typeObj.keys(); nodes.hasNext();) {
                    JSONObject currentNode = typeObj.getJSONObject(nodes.next());
                    if (Arrays.asList(JSONObject.getNames(currentNode)).contains("url")) {
                        urls.add(currentNode.get("url").toString());
                    }
                }
            }
        }

        for (String url : urls) {
            if (isLocalhostURL(url)) {
                return true;
            }
        }
        return false;
    }

    public static void setDiscoverAsLocalHost(boolean isLocalHost) {
        System.setProperty(Config.SERVICE_DISCOVER_AS_LOCALHOST, String.valueOf(isLocalHost));
        System.out.println("local host: " + isLocalHost);
    }
}