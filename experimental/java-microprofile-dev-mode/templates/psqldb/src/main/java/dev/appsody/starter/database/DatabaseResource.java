package dev.appsody.starter.database;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.text.MessageFormat;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("/database")
public class DatabaseResource {

	/**
	 * Get DB client metadata.
	 * 
	 * @return
	 * 
	 * @throws Exception
	 */
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public JsonObject getProperties() throws Exception {

		PaasProperties instance = PaasProperties.getInstance();
		DatabaseCredentials ddc = instance.getDbCredentials();
		if (ddc == null) {
			String errMsg = "Environment variable 'SECRET' is not set!";
			throw new RuntimeException(errMsg);
		}

		JsonObjectBuilder builder = Json.createObjectBuilder();
		try (Connection dbConn = getDbConnection(ddc)) {
			dbConn.getClientInfo().entrySet().stream()
					.sorted((e1, e2) -> ((String) e1.getKey()).compareTo((String) e2.getValue()))
					.forEach(entry -> builder.add("client.info." + (String) entry.getKey(), (String) entry.getValue()));
			DatabaseMetaData metaData = dbConn.getMetaData();
			builder.add("db.product.name", metaData.getDatabaseProductName());
			builder.add("db.product.version", metaData.getDatabaseProductVersion());
			builder.add("db.major.version", metaData.getDatabaseMajorVersion());
			builder.add("db.minor.version", metaData.getDatabaseMinorVersion());
			builder.add("db.driver.version", metaData.getDriverVersion());
			builder.add("db.jdbc.major.version", metaData.getJDBCMajorVersion());
			builder.add("db.jdbc.minor.version", metaData.getJDBCMinorVersion());
		} catch (SQLException e) {
			String errMsg = MessageFormat.format("Unable to retrieve connection metadata from [{0}] due to {1}",
					ddc.jdbcurl, e.getMessage());
			throw new Exception(errMsg, e);
		}

		return builder.build();
	}

	/**
	 * Returns a JDBC connection to the database.
	 * 
	 * @param p database connectivity parameters
	 * 
	 * @return the new JDBC connection
	 * 
	 * @throws Exception if the connection cannot be established for whatever
	 *                       reason.
	 */
	private Connection getDbConnection(DatabaseCredentials p) throws Exception {
		String jdbcDriverName = "org.postgresql.Driver";

		Connection conn = null;

		try {
			Class.forName(jdbcDriverName);
			conn = DriverManager.getConnection(p.jdbcurl, p.username, p.password);
		} catch (SQLException e) {
			String errMsg = MessageFormat.format(
					"Unable to establish connection to database [{0}] due to {1}", p.jdbcurl,
					e.getMessage());
			throw new Exception(errMsg, e);
		}

		return conn;
	}

}
