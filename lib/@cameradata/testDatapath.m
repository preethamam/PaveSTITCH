%
% Get the experimental data folder path
%
%----------------------- Test data path ------------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/13/2014 @ 1:20 PM
%
% Syntax:       output = TESTDATAPATH (obj)
%
% Description:  Adds the experimental data folder to the Matlab
%               path.
%               
% Inputs:       object(obj.datafolderpath, obj.testfolder)
%
% Outputs:      output (experimental folder path)
%               
% Note:         Call this method once. No help in redundency!
%
% SEE ALSO:
% GETTESTDATAPATH, CAMERADATA
%---------------------------------------------------------------
function output = testDatapath (obj)

    % Get the current folder path
    currfolderpath = pwd;

    % Extract the back(forward) slash character position value
    % PC, Mac and Unix compatible
    if (ispc)
        bkslash = regexp(currfolderpath,'\');
    elseif (ismac || isunix)
        bkslash = regexp(currfolderpath,'/');
    end

    % Extract the characters till last back(forward) slash value
    onefolderup = currfolderpath(1:bkslash(end));

    % Add testfolder name after last slash
    % PC, Mac and Unix compatible
    if (ispc)
        if (isempty(obj.datafolderpath))
            output = [onefolderup 'Test DataSets' '\' obj.testfolder '\'];
        else
            output = [obj.datafolderpath '\' obj.testfolder '\'];
        end
    elseif (ismac || isunix)                
        if (isempty(obj.datafolderpath))
            output = [onefolderup 'Test DataSets' '/' obj.testfolder '/'];
        else
            output = [obj.datafolderpath '/' obj.testfolder '/'];
        end
    end            
end