function xmlParametersGui(varargin)
%function xmlParametersGui(varargin)
%xml Parameters Gui Main Function.
%See xmlParametersGui.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%
% -p : Name of the .xml file to build a panel from
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the xmlParametersGui development team.
%
% This file is part of The Triple Dimention Fusion (xmlParametersGui).
%
% xmlParametersGui development has been led by: Daniel Lafontaine
%
% xmlParametersGui is distributed under the terms of the Lesser GNU Public License.
%
%     This version of xmlParametersGui is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
% xmlParametersGui is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with xmlParametersGui.  If not, see <http://www.gnu.org/licenses/>.        
    
    uicontrolPointers('reset');
    paramValues('reset');
    
    varargin = replace(varargin, '"', '');
    varargin = replace(varargin, ']', '');
    varargin = replace(varargin, '[', '');
    
    sDicomFileName = [];

    asMainDir='';
    argLoop=1;
    for ii = 1 : length(varargin)
        sSwitchAndArgument = lower(varargin{ii});
        cSwitch = sSwitchAndArgument(1:2);
        sArgument = sSwitchAndArgument(3:end);
        
        switch cSwitch
%            case '-b'
%                argBorder = true; 
            case '-p'
                argParamFile = strtrim(sArgument); 
                
            otherwise
                asMainDir{argLoop} = sSwitchAndArgument;
                if ~(asMainDir{argLoop}(end) == '\')
                        asMainDir{argLoop} = [asMainDir{argLoop} '\'];                     
                end
                argLoop = argLoop+1; 
        end                          
    end  
    
    if exist('argParamFile')
        s = xml2struct(argParamFile);  
    else
        msgbox('Error: xmlParametersGui(): Please pass a valid .xml parameter file name!', 'Error');
        return;
    end
        
    gdCurrentProtocol = str2double(s.xmlParametersGui.defaultProtocol.Text);

    if numel(s.xmlParametersGui.protocol) == 1
        dNbCol   = numel(s.xmlParametersGui.protocol.columns.columnName); 
    else
        dNbCol   = numel(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnName); 
    end
    
    dColTotalSize = 0;
    if numel(s.xmlParametersGui.protocol) == 1    
        if numel(s.xmlParametersGui.protocol.columns.columnSize) == 1
            dColTotalSize = str2double( s.xmlParametersGui.protocol.columns.columnSize.Text);
        else
            for cc=1: dNbCol
                dColTotalSize = dColTotalSize + str2double(s.xmlParametersGui.protocol.columns.columnSize{cc}.Text);
            end    
        end    
    else
        if numel(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize) == 1
            dColTotalSize = str2double( s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize.Text);
        else
            for cc=1: dNbCol
                dColTotalSize = dColTotalSize + str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize{cc}.Text);
            end    
        end           
    end
        
    dYSize = (getFieldYSize(s, gdCurrentProtocol) * 25) + 150 + 65;
        
    dlgWindowsSizeX = dColTotalSize+30;
    dlgWindowsSizeY = dYSize;

    dScreenSize  = get(groot, 'Screensize');

    dPositionX = (dScreenSize(3) /2) - (dlgWindowsSizeX /2);
    dPositionY = (dScreenSize(4) /2) - (dlgWindowsSizeY /2);
            
    dlgWindows = dialog('Position', [dPositionX dPositionY dlgWindowsSizeX dlgWindowsSizeY],...
                        'Name'    , s.xmlParametersGui.guiName.Text,...
                        'resize'  , 'off'...
                        );
    
%    javaFrame = get(dlgWindows,'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon('.\logo.png'));
        
    txtDefaultProtocol = ...
        uicontrol(dlgWindows,...
                  'style'   , 'text',...
                  'string'  , 'XML Protocol',...
                  'horizontalalignment', 'left',...
                  'position', [20 dlgWindowsSizeY-48 100 25]...
                  );     
          
    if numel(s.xmlParametersGui.protocol) == 1
        sProtocolList = s.xmlParametersGui.protocol.protocolName.Text;
    else
        for pp=1:numel(s.xmlParametersGui.protocol)
            sProtocolList{pp}=s.xmlParametersGui.protocol{pp}.protocolName.Text;
        end
    end
    
    popDefaultProtocol = ...
    uicontrol(dlgWindows,...
             'Style'   , 'popup', ...
             'Position', [120  dlgWindowsSizeY-45 165 25],...
             'enable'  , 'on',...
             'String'  , sProtocolList,...
             'Value'   , str2double(s.xmlParametersGui.defaultProtocol.Text), ...
             'Callback', @protocolCallback...
             );    
         
    btnCancel = ...
    uicontrol(dlgWindows,...
              'String','Cancel',...
              'Position',[dlgWindowsSizeX-115 15 100 25],...
              'Callback', @cancelCallback...
              );  
              
    btnProceed = ...
    uicontrol(dlgWindows,...
              'String','Proceed',...
              'Position',[dlgWindowsSizeX-225 15 100 25],...
              'Callback', @proceedCallback...
              );      
    
        function cancelCallback(~,~)
            delete(dlgWindows);
        end
    
    displayProtocol(str2double(s.xmlParametersGui.defaultProtocol.Text));
    
    function auiPointer = uicontrolPointers(sAction, uiPointer)
        persistent pauiPointer;
        
        if strcmpi(sAction, 'add')
            pauiPointer{numel(pauiPointer)+1} = uiPointer;
        elseif strcmpi(sAction, 'reset')
            pauiPointer = '';
        end
               
        auiPointer = pauiPointer;
    end

    function aValues = paramValues(sAction, aValue)
        persistent paValues;
        
        if strcmpi(sAction, 'add')
            paValues{numel(paValues)+1} = aValue;
        elseif strcmpi(sAction, 'set')
            paValues = aValue;
        elseif strcmpi(sAction, 'reset')
            paValues = '';
        end
        
        aValues = paValues;
    end

    function proceedCallback(~, ~)
        
        sMatFile = [];
        
        if numel(s.xmlParametersGui.protocol) == 1
        
            if isfield(s.xmlParametersGui, 'exportFile')               
                sMatFile = s.xmlParametersGui.exportFile.Text;                
                
            elseif isfield(s.xmlParametersGui.protocol, 'exportFile')               
                
                sMatFile = s.xmlParametersGui.protocol.exportFile.Text; 
            end
        else
            if isfield(s.xmlParametersGui, 'exportFile')               
                sMatFile = s.xmlParametersGui.exportFile.Text;                
                
            elseif isfield(s.xmlParametersGui.protocol{gdCurrentProtocol}, 'exportFile')   

                sMatFile = s.xmlParametersGui.protocol{gdCurrentProtocol}.exportFile.Text;                
            end            
        end
         
        if ~isempty(sMatFile)
            if exist(sMatFile, 'file')
                delete(sMatFile);
            end           
        end
        
        aValues = paramValues('get');  

        for zz=1: numel(aValues)
            xmlParams{zz, 1} = aValues{zz}(1);
            xmlParams{zz, 2} = aValues{zz}(2);
        end
        
        xmlParams = flip(xmlParams);

        if ~isempty(asMainDir)
            arraySize = size(xmlParams);
            for dd=1:numel(asMainDir)                
                xmlParams{arraySize(1)+dd, 1} = 'Dicom Folder';
                xmlParams{arraySize(1)+dd, 2} = asMainDir{dd};
            end
        end

        % If <exportFile></exportFile> is define, save a .mat file of the parameters
        
        if ~isempty(sMatFile)            
            save(sMatFile, 'xmlParams');
        end
        
        delete(dlgWindows);
        
        % If a <functionName></functionName> is define, call the function with the parameters
        
        sFunctionName = [];          
              
        if numel(s.xmlParametersGui.protocol) == 1
            if isfield(s.xmlParametersGui.protocol, 'functionName')
                sFunctionName = s.xmlParametersGui.protocol.functionName.Text;
            end            
        else            
            if isfield(s.xmlParametersGui.protocol{gdCurrentProtocol}, 'functionName')
                sFunctionName = s.xmlParametersGui.protocol{gdCurrentProtocol}.functionName.Text;   
            end
        end        
        
        if ~isempty(sFunctionName)
            eval(sprintf('%s(xmlParams)', sFunctionName));    
        end
    end

    function protocolCallback(hObject, ~)
        
        gdCurrentProtocol = hObject.Value;

        if numel(s.xmlParametersGui.protocol) == 1
            dNbCol = numel(s.xmlParametersGui.protocol.columns.columnName); 
        else
            dNbCol = numel(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnName); 
        end
    
        dColTotalSize = 0;
        if numel(s.xmlParametersGui.protocol) == 1    
            if numel(s.xmlParametersGui.protocol.columns.columnSize) == 1
                dColTotalSize = str2double( s.xmlParametersGui.protocol.columns.columnSize.Text);
            else
                for dd=1: dNbCol
                    dColTotalSize = dColTotalSize + str2double(s.xmlParametersGui.protocol.columns.columnSize{dd}.Text);
                end    
            end    
        else
            if numel(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize) == 1
                dColTotalSize = str2double( s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize.Text);
            else
                for dd=1: dNbCol
                    dColTotalSize = dColTotalSize + str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize{dd}.Text);
                end    
            end           
        end       
        
        dlgWindowsSizeX = dColTotalSize+30;
        
        dYSize = (getFieldYSize(s, gdCurrentProtocol) * 25) + 150 + 45;
        dlgWindowsSizeY = dYSize;
        
        dlgWindows.Position = [dlgWindows.Position(1) dlgWindows.Position(2) dlgWindowsSizeX dlgWindowsSizeY];
        
        txtDefaultProtocol.Position = [20 dlgWindowsSizeY-48 100 25];
        popDefaultProtocol.Position = [120  dlgWindowsSizeY-45 165 25];
        
        btnCancel.Position = [dlgWindowsSizeX-115 15 100 25];
        btnProceed.Position = [dlgWindowsSizeX-225 15 100 25];
        
        auiPointer = uicontrolPointers('get');
        
        for oo=1:numel(auiPointer)
            delete(auiPointer{oo});
        end
        
        uicontrolPointers('reset');
        paramValues('reset');
 
        displayProtocol(hObject.Value);
    end
    
    function YSize = getFieldYSize(s, index)

        YSize = 1;
        
        if numel(s.xmlParametersGui.protocol) == 1
            dNbCol = numel(s.xmlParametersGui.protocol.columns.columnName); 
        else
            dNbCol = numel(s.xmlParametersGui.protocol{index}.columns.columnName); 
        end
        
        for ll=1:dNbCol

            if(dNbCol == 1)
                if numel(s.xmlParametersGui.protocol) == 1
                    tFields = s.xmlParametersGui.protocol.columns.fields;
                else
                    tFields = s.xmlParametersGui.protocol{index}.column.fields;
                end
            else
                if numel(s.xmlParametersGui.protocol) == 1
                    tFields = s.xmlParametersGui.protocol.columns.fields{ll};
                else
                    tFields = s.xmlParametersGui.protocol{index}.columns.fields{ll};
                end
            end

            findFieldOrder(tFields, ll);

        end

        function findFieldOrder(tFields, dColumn)

            if isfield(tFields, 'field')
                dNbFields = numel(tFields.field);      
                for kk=1:dNbFields 
                    if numel(tFields.field) == 1
                        tField = extractOneField(tFields.field);
                    else
                        tField = extractOneField(tFields.field{dNbFields - kk +1});
                    end

                    if YSize < str2double(tField.sOrder)
                        YSize =  str2double(tField.sOrder);
                    end

                    if numel(tFields.field) == 1
                        if isfield(tFields.field, 'field')
                            findFieldOrder(tFields.field, dColumn);
                        end
                    else
                        if isfield(tFields.field{dNbFields - kk +1}, 'field')
                            findFieldOrder(tFields.field{dNbFields - kk +1}, dColumn);
                        end
                    end

                end
            end
        end 
    end
    
    function tField = extractOneField(tField)
        
        if isfield(tField, 'fieldName') 
            tField.sName  = tField.fieldName.Text; end
        
        if isfield(tField, 'fieldType') 
            tField.sType  = tField.fieldType.Text; end        
        
        if isfield(tField, 'fieldValue') 
            tField.sValue = tField.fieldValue.Text; end
        
        if isfield(tField, 'fieldOffset') 
            tField.dValue = str2double(tField.fieldOffset.Text); end
        
        if isfield(tField, 'fieldOrder') 
            tField.sOrder  = tField.fieldOrder.Text; end

        if isfield(tField, 'group') 
            tField.sGroup  = tField.group.Text; end        
        
        if isfield(tField, 'element') 
            tField.sElement  = tField.element.Text; end
        
    end
    
    function displayProtocol(index)   
        
        if numel(s.xmlParametersGui.protocol) == 1
            dNbCol = numel(s.xmlParametersGui.protocol.columns.columnName); 
            if numel(s.xmlParametersGui.protocol.columns.columnSize) == 1
                dColSize = str2double( s.xmlParametersGui.protocol.columns.columnSize.Text);
            else
                dColSize = str2double( s.xmlParametersGui.protocol.columns.columnSize{index}.Text);               
            end
        else
            dNbCol = numel(s.xmlParametersGui.protocol{index}.columns.columnName); 
            if numel(s.xmlParametersGui.protocol{index}.columns.columnSize) == 1
                dColSize = str2double( s.xmlParametersGui.protocol{index}.columns.columnSize.Text);
            else
                dColSize = str2double( s.xmlParametersGui.protocol{index}.columns.columnSize{index}.Text);               
            end
        end
    
        for jj=1:dNbCol

            if(dNbCol == 1)
                if numel(s.xmlParametersGui.protocol) == 1
                    sColName = s.xmlParametersGui.protocol.columns.columnName.Text;
                    tFields  = s.xmlParametersGui.protocol.columns.fields;
                else
                    sColName = s.xmlParametersGui.protocol{index}.columns.columnName.Text;
                    tFields  = s.xmlParametersGui.protocol{index}.columns.fields;
                end
            else
                if numel(s.xmlParametersGui.protocol) == 1
                    sColName = s.xmlParametersGui.protocol.columns.columnName{jj}.Text;
                    tFields  = s.xmlParametersGui.protocol.columns.fields{jj};
                else
                    sColName = s.xmlParametersGui.protocol{index}.columns.columnName{jj}.Text;
                    tFields  = s.xmlParametersGui.protocol{index}.columns.fields{jj};
                end
            end
            
            dColOffset = 0;
            if numel(s.xmlParametersGui.protocol) == 1
                if numel(s.xmlParametersGui.protocol.columns.columnSize) == 1
                    dColSize   = str2double(s.xmlParametersGui.protocol.columns.columnSize.Text);
                    dColOffset = 0;
                else
                    dColSize   = str2double(s.xmlParametersGui.protocol.columns.columnSize{jj}.Text);               
                    for ff=1: jj-1
                        dColOffset = dColOffset + str2double(s.xmlParametersGui.protocol.columns.columnSize{ff}.Text);               
                    end
               end
            else
                if numel(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize) == 1
                   dColSize   = str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize.Text);
                   dColOffset = 0;
               else
                    dColSize   = str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize{jj}.Text);               
                    for ff=1: jj-1
                        dColOffset = dColOffset + str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize{ff}.Text);               
                    end
               end
            end
            
            uicontrolPointers('add', ...
            uicontrol(dlgWindows,...
                      'style'   , 'text',...
                      'string'  , sColName,...
                      'horizontalalignment', 'left',...
                      'position', [dColOffset+16 dlgWindowsSizeY-40-45 dColSize 20]...
                      ));   
                  
            setFieldsUiControl(tFields, jj, 1);

        end

        function setFieldsUiControl(tFields, index, dSub)

            if isfield(tFields, 'field')
                dNbFields = numel(tFields.field);   
                for kk=1:dNbFields 

                    if numel(tFields.field) == 1
                        tField = extractOneField(tFields.field);
                    else
                        tField = extractOneField(tFields.field{dNbFields - kk +1});
                    end

                    displayUiControl(tField, index, dSub);

                    if numel(tFields.field) == 1
                        if isfield(tFields.field, 'field')
                      %      dSub = dSub+1;
                            setFieldsUiControl(tFields.field, index, dSub+1);
                        end
                    else
                        if isfield(tFields.field{dNbFields - kk +1}, 'field')
                      %      dSub = dSub+1;
                            setFieldsUiControl(tFields.field{dNbFields - kk +1}, index, dSub+1);
                        end
                    end

                end
            end

        end

        function displayUiControl(tField, index, dSub)
            
            dColOffset = 0;
            if numel(s.xmlParametersGui.protocol) == 1
                if numel(s.xmlParametersGui.protocol.columns.columnSize) == 1
                    dColSize   = str2double(s.xmlParametersGui.protocol.columns.columnSize.Text);
                    dColOffset = 0;
                else
                    dColSize   = str2double(s.xmlParametersGui.protocol.columns.columnSize{index}.Text);               
                    for uu=1: index-1
                        dColOffset = dColOffset + str2double(s.xmlParametersGui.protocol.columns.columnSize{uu}.Text);               
                    end
               end
            else
                if numel(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize) == 1
                   dColSize   = str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize.Text);
                   dColOffset = 0;
               else
                    dColSize   = str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize{index}.Text);               
                    for uu=1: index-1
                        dColOffset = dColOffset + str2double(s.xmlParametersGui.protocol{gdCurrentProtocol}.columns.columnSize{uu}.Text);               
                    end
               end
            end
            
            switch tField.sType
                
                case  'dicomread'

                        uicontrolPointers('add', ...
                        uicontrol(dlgWindows,...
                                  'style'   , 'text',...
                                  'string'  , tField.sName,...
                                  'horizontalalignment', 'left',...
                                  'position', [dColOffset+16+((dSub-1)*30) dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-23-45 dColSize-150 25]...
                                  ));  
                              

                        
                        
                        if ~isempty(sDicomFileName)
                            
                            tMetadata = dicominfo(sDicomFileName);
                            sValue = tMetadata.(dicomlookup(tField.sGroup, tField.sElement));  
                        else
                            if ~isempty(asMainDir)
                                
                                tFileInfo = dir(asMainDir{1});
                                aAllNames = {tFileInfo.name};
                                for nn=1:numel(aAllNames)
                                    sCurFile = sprintf('%s%s',asMainDir{1}, aAllNames{nn});
                                    try
                                        if isdicom(sCurFile)
                                            sDicomFileName = sprintf('%s%s',asMainDir{1}, aAllNames{nn});
                                            break;
                                        end
                                    catch
                                        % file is not dicom, continue
                                    end
                                end
                                
                                if ~isempty(sDicomFileName)
                                    tMetadata = dicominfo(sDicomFileName);
                                    sValue = tMetadata.(dicomlookup(tField.sGroup, tField.sElement));                                
                                else
                                    msgbox('Error: xmlParametersGui(): Cant use dicomread feature without passing a valid dicom file name!', 'Error');
                                    return;                                    
                                end
                            else   
                                msgbox('Error: xmlParametersGui(): Cant use dicomread feature without passing a valid dicom folder name!', 'Error');
                                return;
                            end
                        end
                        
                        if isstruct(sValue)
                            
                            %struct to cell
                            celValue = struct2cell(sValue);
                            aValueSize = size(celValue);
                            
                            celValue = reshape(celValue,1,aValueSize(1));
                            
                            %cell to matrix
                            matValue = cell2mat(celValue);
                            
                            %matrix to char
                            sValue = mat2str(matValue);
                            
                            %adding spaces and removing extra characters
                            sValue = strrep(sValue,';',' ');
                            sValue = strrep(sValue,'[','');
                            sValue = strrep(sValue,']','');   
                        else
                            if ~ischar(sValue)
                                sValue = sprintf('%d', sValue);
                            end                            
                        end 
                        
                        ui = uicontrol(dlgWindows,...
                                  'enable'    , 'off',...
                                  'style'     , 'edit',...
                                  'Background', 'white',...
                                  'string'    , sValue,...
                                  'position'  , [dColOffset+150+((dSub-1)*30)  dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-20-45 150 25],...
                                  'Callback', @uiCallback...                          
                                  );      
                              
                        uicontrolPointers('add', ui);
                              
                        aValue{1,1} = tField.sName;
                        aValue{1,2} = sValue;
                        aValue{1,3} = ui;
                             
                        paramValues('add', aValue);
                        
                case  'edit'
                    
                        uicontrolPointers('add', ...
                        uicontrol(dlgWindows,...
                                  'style'   , 'text',...
                                  'string'  , tField.sName,...
                                  'horizontalalignment', 'left',...
                                  'position', [dColOffset+16+((dSub-1)*30) dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-23-45 dColSize-105 25]...
                                  ));  

                        ui = uicontrol(dlgWindows,...
                                  'enable'    , 'on',...
                                  'style'     , 'edit',...
                                  'Background', 'white',...
                                  'string'    , tField.sValue,...
                                  'position'  , [dColOffset+150+((dSub-1)*30)  dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-20-45 105 25],...
                                  'Callback', @uiCallback...                          
                                 );  
                             
                        uicontrolPointers('add', ui);
                             
                        aValue{1,1} = tField.sName;
                        aValue{1,2} = tField.sValue;
                        aValue{1,3} = ui;
                            
                        paramValues('add', aValue);
 
                case  'text'
                    
                        uicontrolPointers('add', ...
                        uicontrol(dlgWindows,...
                                  'style'   , 'text',...
                                  'string'  , tField.sName,...
                                  'horizontalalignment', 'left',...
                                  'position', [dColOffset+16+((dSub-1)*30) dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-23-45 dColSize-105 25]...
                                  ));                      
                        
                    case  'checkbox'

                        ui = uicontrol(dlgWindows,...
                                  'style'   , 'checkbox',...
                                  'enable'  , 'on',...
                                  'value'   , str2double(tField.sValue),...
                                  'position', [dColOffset+20+((dSub-1)*30)  dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-20-45 25 25],...
                                  'Callback', @uiCallback...                          
                                  );  
                              
                         uicontrolPointers('add', ui);
                             
                        uicontrolPointers('add', ...
                        uicontrol(dlgWindows,...
                                  'style'   , 'text',...
                                  'string'  , tField.sName,...
                                  'horizontalalignment', 'left',...
                                  'position', [dColOffset+45+((dSub-1)*30)  dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-23-45 dColSize-25 25]...
                                 ));    
                              
                        aValue{1,1} = tField.sName;
                        aValue{1,2} = tField.sValue;
                        aValue{1,3} = ui;
                            
                        paramValues('add', aValue);
                        
                    case  'popup'

                        uicontrolPointers('add', ...
                        uicontrol(dlgWindows,...
                                  'style'   , 'text',...
                                  'string'  , tField.sName,...
                                  'horizontalalignment', 'left',...
                                  'position', [dColOffset+16+((dSub-1)*30) dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-23-45 dColSize-165 25]...
                                  ));     
                       
                              
                       ui = uicontrol(dlgWindows,...
                                 'Style'   , 'popupmenu', ...
                                 'Position', [dColOffset+150+((dSub-1)*30)  dlgWindowsSizeY-((str2double(tField.sOrder)+1)*30)-20-45 165 25],...
                                 'enable'  , 'on',...
                                 'String'  , split(tField.sValue, ','),...
                                 'Value'   , tField.dValue, ...
                                 'Callback', @uiCallback...                          
                                 );    
                             
                        uicontrolPointers('add', ui);
                            
                        aValue{1,1} = tField.sName;
                        aValue{1,2} = ui.String{ui.Value};
                        aValue{1,3} = ui;
                             
                        paramValues('add', aValue);       
            end     

        end
        
        function uiCallback(hObject, ~)
            
            aValues = paramValues('get');
            
            switch hObject.Style 
                case 'popupmenu'
                    newValue = hObject.String{hObject.Value};
                otherwise
                    newValue = hObject.String;
            end
            
            for vv=1:numel(aValues)
                aValue = aValues{vv};
                if hObject == aValue{3}
                    aValue{2} = newValue;
                    aValues{vv} = aValue;
                    break;
                end
            end
            
            paramValues('reset');
            
            paramValues('set', aValues);
            
        end
    end

end