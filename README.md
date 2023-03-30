## BuildJRE Usage Guide

The following steps will guide you on how to use BuildJRE to create a customized slim version of the JRE for your Maven-based project:

1. Download the BuildJRE script.
2. Place the script in the root directory of your Maven project, alongside the pom.xml file.
3. Build your project using the "mvn package" command or any similar command that generates a single jar file in the "/target/" directory.
4. Run the BuildJRE script.
5. The script will generate a customized slim version of the JRE, which will be located in the "/custom-jre/" directory.
6. If execution of your project using the custom JRE fails, you can add the unresolved dependencies to a file named ".unresolvable.deps". Each dependency should be on a separate line in the file.
7. After modifying the ".unresolvable.deps" file, rerun the BuildJRE script.

By following these steps, you can easily create a customized slim version of the JRE for your Maven project, which can improve the performance of your application and reduce its overall size.
