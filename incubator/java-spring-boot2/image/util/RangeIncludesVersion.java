import org.osgi.framework.VersionRange;
import org.osgi.framework.Version;

public class RangeIncludesVersion {

    public static void main(String[] args) {
        if ( args.length < 2 ) {
            System.out.println("Must specify range and version");
            System.exit(1);
        }
        String range = args[0];
        String version = args[1];

        boolean result = VersionRange.valueOf(range).includes(Version.valueOf(version));
        System.exit( result ? 0 : 1 );
    }
}
