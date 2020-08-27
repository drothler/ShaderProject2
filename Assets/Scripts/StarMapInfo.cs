[System.Serializable]
public class StarMapInfo
{
    public StarValues[] starmap;

    public StarMapInfo(){

    }

    public string getString()
    {
        string output="";
        foreach(StarValues s in starmap){
            output+="RA: "+s.RA+" DEC: "+s.DEC+" MAG: "+s.MAG;
        }
        return output;
    }

    
}
[System.Serializable]
public class StarValues
{
    public int harvard_ref;
    public string RA;
    public string DEC;

    public int Epoch;

    public string RAPM;
    public string DECPM;

    public string MAG;

    public string Title;

    public StarValues(){

    }
}
