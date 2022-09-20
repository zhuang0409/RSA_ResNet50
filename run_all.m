% code folder: /Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/progs
subjectIDs = {'SUB03_19980219SNFS','SUB04_19900101WALE','SUB05_19890101WANL','SUB06_19880720WAVI'...
              'SUB07_19960420WIST','SUB08_19980101THAE','SUB09_20200828NICA','SUB10_20200828LYXU'...
              'SUB11_19920409THZH','SUB12_19980908SABA','SUB13_19940216NARA','SUB14_19971002COCA'...
              'SUB15_19970428MIRU','SUB16_19891030CHZH','SUB17_19921010XIHA','SUB18_19921211ZUKA'...
              'SUB19_19970603JOBE','SUB20_19970125FIGI','SUB21_19940526MISC','SUB22_19891024ROPU'...
              'SUB23_19811010CHZW','SUB24_20200918ANIO','SUB25_20200923MICA'};
          


for x=1:length(subjectIDs)
    subID=char(subjectIDs(x));
    a=[1:3, 10:11,20:23,25:54];
    for j=1:5
        disp(a(j))
        if a(j)<10
        foldernames=sprintf('RNaction0%d',a(j));
        else
            foldernames=sprintf('RNaction%d',a(j));
        end
        disp(foldernames)
        A03_runRSA_DNNs(subID,foldername,a(j));
    end
end

