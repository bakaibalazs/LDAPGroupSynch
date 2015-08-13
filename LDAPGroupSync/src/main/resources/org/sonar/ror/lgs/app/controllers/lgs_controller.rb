require 'java'

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.lang.System
import javax.naming.Context
import javax.naming.NamingEnumeration
import javax.naming.directory.InitialDirContext
import javax.naming.directory.SearchControls
import javax.naming.directory.SearchResult


class LgsController < ApplicationController    
  SECTION=Navigation::SECTION_CONFIGURATION 
  before_filter :admin_required
  
  def index           
    puts "-INDEX"                         
  end
  
  
  def synchLDAP
    puts "-SYNCH LDAP"
    
    ldapGroupNames=getLDAPGRoupNames
    sonarGroups=Group.find(:all, :order => 'name')
                       
    insertedRows=insertNewLDAPGroupsToSonarDb(java.util.ArrayList.new(sonarGroups.map{|g| g.name }),ldapGroupNames)
    deletedRows=deleteRemovedLDAPGroupsFromSonarDB(sonarGroups,ldapGroupNames)    
        
    flash[:notice] = "You inserted #{insertedRows} row(s) and deleted #{deletedRows} row(s) from SonarQube DB!"    
    redirect_to :action => 'index'        
  end
  
   
  private
    def getLDAPGRoupNames
      puts 'get LDAP Group Names'
      
      properties = Properties.new();
      properties.put( Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory" );
      properties.put( Context.PROVIDER_URL, findSettingsValueByName('ldap.url'));
      properties.put( Context.REFERRAL, "ignore" );
      properties.put( Context.SECURITY_PRINCIPAL,  findSettingsValueByName('ldap.bindDn') );
      properties.put( Context.SECURITY_CREDENTIALS, findSettingsValueByName('ldap.bindPassword'));
      context = InitialDirContext.new(properties );
      searchCtls = SearchControls.new();
      searchCtls.setSearchScope(2);
      String searchFilter = "(objectClass=group)";
      searchCtls.setReturningAttributes([findSettingsValueByName('ldap.group.idAttribute')].to_java :String);
      answer = context.search( findSettingsValueByName('ldap.group.baseDn'), searchFilter, searchCtls );        
      
      ldapGroupNames = java.util.ArrayList.new
      
      for item in answer
        cn =item.getAttributes().get(findSettingsValueByName('ldap.group.idAttribute'))           
        if  cn != nil
          ldapGroupNames << cn.toString[4,999]
        end       
      end
     
      return ldapGroupNames
   end  
   
   private
    def findSettingsValueByName(name)
      return Java::OrgSonarServerUi::JRubyFacade.getInstance().getSettings().getString(name)
    end   
  
  
  private 
    def insertNewLDAPGroupsToSonarDb(sonarDBGroupNames,ldapGroupNames)
      puts 'insert new ldap groups to SonarQube DB'
      
      numOfInsertedRows=0;
      
      for ldapGroupName in ldapGroupNames           
        if(!sonarDBGroupNames.contains(ldapGroupName))
          numOfInsertedRows+=1;          
          Group.create(:name => ldapGroupName, :description => 'LDAP_GROUP') 
          puts "#{ldapGroupName} ldap group inserted to sonardb"
        end
      end      
      
      puts "number of inserted rows: #{numOfInsertedRows}"      
      return numOfInsertedRows;
    end
  
  private
    def deleteRemovedLDAPGroupsFromSonarDB(sonarGroups,ldapGroupNames)
      puts 'delete removable ldap groups from SonarQube DB'                
      
      removableGroups = java.util.ArrayList.new(sonarGroups.map{|g| g.name })
      removableGroups.removeAll(ldapGroupNames)
      removableGroups.remove("sonar-users");
      removableGroups.remove("sonar-administrators");
      
      numOfDeletedRows=0;
      
      for rgrp in removableGroups        
        rgroup=Group.find(:first, :conditions => {:name => rgrp})        
        rgroup.destroy        
        puts "#{rgroup.name}(#{rgroup.id})  group deleted from SonarQube DB"          
        numOfDeletedRows+=1;
      end
      
      puts "#{numOfDeletedRows} group(s) deleted from SonarQube DB"
      return numOfDeletedRows                     
    end
end