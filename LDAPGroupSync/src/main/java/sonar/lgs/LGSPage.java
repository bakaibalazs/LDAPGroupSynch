package sonar.lgs;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sonar.api.web.NavigationSection;
import org.sonar.api.web.Page;
import org.sonar.api.web.UserRole;

@NavigationSection(NavigationSection.CONFIGURATION)
@UserRole(UserRole.ADMIN)
public final class LGSPage implements Page {
	
	private Logger logger = LoggerFactory.getLogger(getClass());
	
	public String getId() {		
		return "/lgs/index";
	}

	public String getTitle() {
		return "LDAP Group Synchronizer";
	}
}