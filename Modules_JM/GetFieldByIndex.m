function Data = GetFieldByIndex(S, n)
C    = struct2cell(S);
Data = C{n}; 