package dev.appsody.starter.database;

import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;

/**
 * Contains all runtime properties stored in the PaaS subsystem in association
 * with the application.
 */
public class PaasProperties {

	/**
	 * Singleton instance.
	 */
	private static PaasProperties instance;

	/**
	 * Singleton constructor.
	 */
	public static synchronized PaasProperties getInstance() throws Exception {
		if (null == instance) {
			instance = new PaasProperties();
			instance.readPaaSProperties();
		}
		return instance;
	}

	/**
	 * Private constructor for singleton pattern
	 */
	private PaasProperties() {
	}

	/**
	 * Retrieves the settings for this application instance.
	 */
	private void readPaaSProperties() throws Exception {
		getDbCredentials();
	}

	/**
	 * @return database credentials read from a container/pod secret
	 */
	public DatabaseCredentials getDbCredentials() throws Exception {
		DatabaseCredentials result = null;

		// TODO: Replace the bindingEnv assignment with reading the credentials 
		// from a secret variable or mounted file.

		String bindingEnv = "{\"jdbcurl\": \"jdbc:postgresql://workshop-postgres:5432/\"," +
				"\"username\": \"postgres\"," +
				"\"password\": \"mysecretpassword\"}";
		if (null != bindingEnv) {
			Jsonb jsonb = JsonbBuilder.create();
			result = jsonb.fromJson(bindingEnv, DatabaseCredentials.class);
		}
		return result;
	}

}
