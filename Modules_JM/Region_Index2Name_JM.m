function Name = Region_Index2Name_JM(idx)
switch idx
                case 1
                    Name='SUB';
                case 2
                    Name='CA1';
                case 3
                    Name='CA3';
                case 4
                    Name='CA3 (DG lesion)';
                otherwise
                    Name='UnKnown';
end
end