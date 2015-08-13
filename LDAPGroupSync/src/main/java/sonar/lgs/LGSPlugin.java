package sonar.lgs;

import org.sonar.api.Properties;
import org.sonar.api.Property;
import org.sonar.api.SonarPlugin;

import java.util.Arrays;
import java.util.List;


@Properties({
    @Property(
        key = LGSPlugin.MY_PROPERTY,
        name = "LDAPGroupSync",
        description = "LDAP Group Synchronizer Plugin")})
public final class LGSPlugin extends SonarPlugin {

  public static final String MY_PROPERTY = "lgs"; 

  
  public List getExtensions() {
    return Arrays.asList(LGSPage.class);    
  }
  
}