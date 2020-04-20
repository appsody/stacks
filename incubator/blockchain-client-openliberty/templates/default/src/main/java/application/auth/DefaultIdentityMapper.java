package application.auth;

import application.cm.ConnectionConfiguration;

public class DefaultIdentityMapper implements IdentityMapper {
    @Override
    public String getFabricIdentity(String principal) {
        return ConnectionConfiguration.getFabricDefaultIdentity();
    }
}