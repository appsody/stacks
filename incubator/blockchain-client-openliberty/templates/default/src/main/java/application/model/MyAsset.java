package application.model;

public class MyAsset {
    private String myAssetId = null;
    private String value = null;

    public MyAsset(){
    }

    public MyAsset(String myAssetId, String value) {
        this.myAssetId = myAssetId;
        this.value = value;
    }

    public String getMyAssetId() {
        return myAssetId;
    }

    public void setMyAssetId(String myAssetId) {
        this.myAssetId = myAssetId;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return "MyAsset [myAssetId=" + myAssetId + ", value=" + value + "]";
    }

}