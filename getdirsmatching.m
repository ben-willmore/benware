function data = getdirsmatching(searchstring)

if ispc
    data = getfilesmatching(searchstring);
end
