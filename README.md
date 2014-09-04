# Description
Configures and sets up the Monasca api. Includes attributes for log backups, ossec file watching and ossec rules.
Also included is an icinga check for the service health check.

Using Vertica
------------
If Vertica is used as the database for Monasca, the Vertica JDBC jar that matches the Vertica version must be placed in /opt/monasca/vertica. The jar from Vertica will be named like vertica-jdbc-7.0.1-0.jar and must be renamed to vertica_jdbc.jar when placed in /opt/monasca/vertica. You can find the Vertica JDBC jar in /opt/vertica/java on a system with the Vertica database installed. This cookbook will copy the Vertica JDBC Jar from /vagrant and place it in /opt/monasca/vertica if run using Chef Solo.
