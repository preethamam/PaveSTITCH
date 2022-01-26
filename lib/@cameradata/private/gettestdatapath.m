%
% Get the experimental data folder path
%
%--------------------- Get test data path ---------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/13/2014 @ 1:20 PM
%
% Syntax:       folderpath = GETTESTDATAPATH (DATAFOLDERPATH, TESTFOLDER)
%
% Description:  Adds the experimental data folder to the Matlab
%               path.
%               
% Inputs:       datafolderpath - Path of the main data sets folder. One
%                                folder above the TESTFOLDER
%               testfolder     - Folder that contains files to process
%
% Outputs:      folderpath (experimental folder path)
%               
% Note:         Call this method once. No help in redundency!
%
% SEE ALSO:
% CAMERADATA
%--------------------------------------------------------------
 function folderpath = gettestdatapath (datafolderpath, testfolder)


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
        if (isempty(datafolderpath))
            folderpath = [onefolderup 'Test DataSets' '\' testfolder '\'];
        else
            folderpath = [datafolderpath '\' testfolder '\'];
        end
    elseif (ismac || isunix)                
        if (isempty(datafolderpath))
            folderpath = [onefolderup 'Test DataSets' '/' testfolder '/'];
        else
            folderpath = [datafolderpath '/' testfolder '/'];
        end
    end           
 end