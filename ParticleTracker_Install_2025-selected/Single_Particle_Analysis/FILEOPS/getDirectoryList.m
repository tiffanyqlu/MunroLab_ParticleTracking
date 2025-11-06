function dirList = getDirectoryList(basename)
%getDirectoryList returns a list of directories with names "basename1",
%"basename2", ...

%  Inputs
%
%   basename =         a string defineing the directory basename  
%
%   Outputs
%
% 	dirList =           A cell array of strings defining the names of
% 	                    individual directories


    dirList = extractfield(dir,'name');
    dirList = dirList((arrayfun(@(x) contains(x,basename + digitsPattern),dirList)));
    dirList = dirList((cellfun(@isfolder,dirList)));

end