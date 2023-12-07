                   
function Binned = Binning_JM(BinSz,x,y,DataWidth)
Binned =[];

                    for BinNum = 1:DataWidth/BinSz+1
                        BinMin = BinSz*(BinNum-1)+100;
                        id = find(and(x>=BinMin,x<BinMin+BinSz));
                        Binned(BinNum,1) = BinMin;
                        Binned(BinNum,2) = mean(y(id));
                        Binned(BinNum,3) =  std(y(id));
                         Binned(BinNum,4) =  std(y(id))/sqrt(size(y(id),1));
                    end