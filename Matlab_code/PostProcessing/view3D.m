function varargout=view3D(varargin)
%VIEW3D Viewer for 3D images
%
% Shows the three orthogonal planes of the volumic image.
% For this viewer we consider matrices to represent 2D or 3D images. 
% The viewer can also show the three planes in a 3D view in a separate
% figure (3D slicer).
%
% The planes can be selected by pressing the middle mouse button or
% shift+left mouse button in the image planes. Clicking on the left
% mouse button shows the value at the current location. Planes
% can also be specified by entering them in the upper left text boxes.
%
% View3D can also show vector fields. The vectors are shown only for 
% the currently visible planes. The scaling as well as the color of
% the vectors can be specified in the field menus.
%
% By selecting other viewers in the link menu, all linked viewers will 
% show the same planes. This is usefull when comparing different images
%
% The intensity scale of the images can be chosen with the sliders
% at the bottom of the figure, or by entering the values in the 
% text boxes next to them. The upper slider sets the minimum intensity
% limit, and the lowest slider sets the maximum intensity. The 
% colormap can be selected in the colormap submenu.
%
% The user is encouraged to explore all other undocumented features
% himself and eventually contribute some documentation for them :-) 
%
% view3D(NAME) opens a viewer and loads image NAME, where name 
%              is the image name string.
%
% view3D(M)    shows matrix M where M can be a 2D or 3D matrix.
% 
% view3D(C)    opens a viewer for all elements of the cell array C
%
% view3D(C,'link') same as previous ut links viewers
%
% view3D(M,F)  shows image matrix M, and vector field F. F is a structure
%              containing the fields u,v,w with the definition of the 
%              vector, and x,y,z with the positions of the vectors.
%              Please note that x corresponds to first dimension of
%              the matrix (like in ndgrid, not like in meshgrid).
%        
%
% Examples:
%    %show random 3D matrix
%    m = randn(25,25,25);
%    view3D(m)
%    
%    % open two linked viewers
%    c{1} = randn(25,25,25); c{2} = randn(25,25,25)
%    view3D(c,'link')
%
%    %show an image and a vector field of only three vectors
%    % go through the image planes to see the vectors
%    m = randn(10,10,10);
%    f.x= [2 3 4]; f.y=[ 4 5 6]; f.z=[6 4 2];
%    f.u= [1 -1 1]; f.v= [ 1 0 2]; f.w= [ 2 3 -2];
%    view3D(m,f);




% $Id: view3D.m,v 1.5 2003/10/26 17:46:45 gflandin Exp $ 
% $Log: view3D.m,v $
% Revision 1.5  2003/10/26 17:46:45  gflandin
% Added flip
%
% Revision 1.4  2003/08/24 13:30:48  gflandin
% Added Evaluate Function tool
%
% Revision 1.3  2003/08/11 11:47:47  gflandin
% Added 'Go to value' option
%
% Revision 1.2  2003/05/27 11:36:40  gflandin
% Update description
%
% Revision 1.1.1.1  2003/02/19 17:31:41  jstoecke
% New image matlab toolbox
%
% Revision 1.12  2003/02/19 14:50:27  jstoecke
% A lot of small updates and bugfixes, window menu
%
% Revision 1.11  2002/12/04 10:37:05  jstoecke
% Removed neurological bug with power zoom
%
% Revision 1.10  2002/12/03 20:00:17  jstoecke
% Removed some neurological bugs
%
% Revision 1.9  2002/12/03 17:44:11  jstoecke
% added neurological convention
%
% Revision 1.8  2002/08/20 13:31:38  jstoecke
% Looks only for view3D tag in figures
%
% Revision 1.7  2002/07/10 09:27:40  jstoecke
% Corrected bug: chose isovalue was not used
%
% Revision 1.6  2002/06/21 13:54:28  jstoecke
% Set handle visibility of value set figures to off
%
% Revision 1.5  2002/06/21 13:34:13  jstoecke
% Changed some UI bugs, clarified some menu names
%
% Revision 1.4  2002/06/21 12:35:31  jstoecke
% Changed menu organisation
%
% Revision 1.3  2002/06/20 07:53:48  jstoecke
% Test commit
%



if nargin==0
    %give chance to select file to open
    % if no input argument where provided
    h=doOpenMenu;
    if nargout>0
        varargout{1}=h;
    end
    return;
end


%if input is simply a handle then just do command
% commands are not used for callbacks, but for extrenal calls
if nargin>1&ishandle(varargin{1})&isstr(varargin{2})
    if strcmp(varargin{2},'redraw')
        %ask for a redraw
        redrawAll(varargin{1});
        return
    end
    if strcmp(varargin{2},'resetaxes')
        %reset axes, if size changed
        setAxesPositions(varargin{1});
        setImageInAxes(varargin{1});
        return
    end
    if strcmp(varargin{2},'newimage')
        %set new image
        setNewImage(varargin{1},varargin{2});
        return
    end
    if strcmp(varargin{2},'pos')
        %set position
        sets=getappdata(varargin{1},'ViewerSettings');
        %check if valid
        imsize=getappdata(varargin{1},'imsize');
        pos=max(min(round(varargin{3}),imsize),[1 1 1]);
        sets.plane=pos;
        setappdata(varargin{1},'ViewerSettings',sets);
        redrawAll(varargin{1});
        return
    end
end



% if first input is cell array, 
% dispatch different images to different viewers
if iscell(varargin{1}) 
    % link figures
    if nargin>1
        v=2:nargin;
        link=v(strcmp(varargin{2:end},'link'));        
    else
        link=0;
    end
    for i=1:length(varargin{1})
        try
            if nargin>1
                % pass other arguments along
                h(i)=feval(mfilename,varargin{1}{i},varargin{setdiff(2:end,link)});
            else
                h(i)=feval(mfilename,varargin{1}{i});
            end
        catch
            warning(sprintf('Failed to process viewer %i',i));
            h(i)=-1;
        end
    end
    % link figures
    if any(link)
        for v=h
            %only link valid figures
            if v~=-1
                setappdata(v,'LinkFigs',setdiff(h,-1));
            end
        end
    end
    % return viewer handle(s) to caller
    if nargout>0
        varargout{1}=h;
    end
    % after having started up all viewers kill this one
    return
end


% check if input is image
if isnumeric(varargin{1})|islogical(varargin{1})
    image_input=1;
else
    image_input=0;    
    switch varargin{1}
        % startup viewer with special settings
    case 'filename'
        image_input=2;
    otherwise
        % if no string matches special cases, then it must be an image name
        image_input=1;
    end
    % warn if file exists with same name as special settings
    if ~image_input
        if exist(varargin{1},'file')
            warning('Ambiguity: file with same option name exists');
        end
    end
end

% case of matrix as input
if image_input
    %special case give viewer settings 
    %as second input argument
    if nargin==2&isstruct(varargin{2})&isfield(varargin{2},'settings')
        
        h=initViewer(varargin{2});
    else
        h=initViewer;
    end
    if ~isstr(varargin{1})
        ima=varargin{1};
        % second argument may be the position of voxels of the image
        if (nargin>1)&(isnumeric(varargin{2})|islogical(varargin{1}))&~isstruct(varargin{2})
            % number of elements must match position mask
            if prod(size(varargin{1}))==sum(varargin{2}(:)>0)
                ima=posima2ima(varargin{1},varargin{2});
            else
                warning('Did not process position image (invalid size)');
            end
        end
        setappdata(h,'Mode','matrix');
    else
        setappdata(h,'Mode','file');
        ima=loadImage(h,varargin{image_input});
    end
    
    sets=getappdata(h,'ViewerSettings');
    sets.labels=0;
    % parse input arguments 
    if (nargin>=2)
        %loop over input arguments
        for i=2:nargin
            if(isstruct(varargin{i}))
                %vector field
                if isfield(varargin{i},'w')
                    setNewField(h,varargin{i});
                    sets.field=1;
                end
                %image header
                if isfield(varargin{i},'vx')
                    setappdata(h,'Header',varargin{i});
                    sets.header=1;
                    
                end
            end
            %check for label names
            if iscell(varargin{i})
                setappdata(h,'Labels',varargin{i})
                sets.labels=1;
                set(getappdata(h,'LabelText'),'visible','on');
            end
            %check for string inputs, for extra options
            if nargin>i&isstr(varargin{i})
                switch lower(varargin{i})
                case 'positionfunction'                    
                    sets.posfunc=varargin{i+1};
                    i=i+1;
                end
            end            
        end
    end
    setappdata(h,'ViewerSettings',sets);
    
    setNewImage(h,ima);
    
    % if last input argument is string, then make this the image name
    if isstr(varargin{end})
        setName(h,varargin{end});
    end
end

%switch off visibility
set(h,'HandleVisibility','callback');

% return viewer handle(s) to caller
if nargout>0
    varargout{1}=h;
end

winmenu(h);  % Initialize the submenu
%end of direct function, rest is done with the callbacks
return



function h=initViewer(c_h)
% test if settings are available in caller, else create new settings
if (nargin==1)&(ishandle(c_h))&(isappdata(c_h,'ViewerSettings'))
    sets_user=getappdata(c_h,'ViewerSettings');
else
    %default settings can also be provided by setting
    % global variable gbl_viewer_settings
    global gbl_view3D_settings
    if ~isempty(gbl_view3D_settings)
        sets_user=gbl_view3D_settings;
    else
        sets_user=[];
    end
    %merge settings
    if nargin==1
        names=fieldnames(c_h);
        for i=1:length(names);
            if ~isfield(sets_user,names{i})
                sets_user = setfield(sets_user,names{i},getfield(c_h,names{i}));
            end
        end
    end    
end


%settings for slice viewers, all three are on
sets.viewers=[1 2 3];
% image planes 
sets.plane=[1 1 1];
% background color, defaults to dark grey
sets.backgroundcolor=[0.5 0.5 0.5];
% frame color, defaults to dark grey
sets.framecolor=[0.75 0.75 0.75];
sets.scaling='manual';
sets.clim=[-1 1; -1 1 ;-1 1];
sets.scale_master=0;
sets.show_cross=1;
%crosshiar default line thickness
sets.cross_thick=0.5;
sets.field=0;
sets.fieldcolor=[0 0 1];
sets.fieldscale=1;
sets.zoom=0;
sets.own_zoom=0;
sets.own_zoom_factor=1;
sets.own_zoom_linked=0;
sets.labels=0;
%swicth on drawing
sets.draw=0;
%switch draw whole block or plane only
sets.block=0;
%default to workspace variable name
sets.varname='';
sets.drawcolor=0.0;
sets.usevoxelsize=0;
sets.header=0;
sets.startcmap='jet';
%set figure image rendering properties
%see figure properties help
sets.doublebuffer='on';
sets.backingstore='on';
%set to true if viewer depends on a mixer
sets.ismixer=0;
%contains hanlde of mixer window
sets.mixer=[];
%set to true if MIP
sets.mip=0;
%set to true if 3D slicer
%if set to true figure for slicer must exist Slicer
sets.slicer=0;
% axes to which 3D thing are added
% zero is new figure
sets.addaxes=0;
%if viewer runs with rgb or native images
sets.RGB=0;
%aphamap type
% 1 none
% 2 th<
% 3 th>
% 4 im>
sets.alphamap=1;
sets.alphathresh=1;
sets.isovaluethresh = 0.5;
%convention of first plane
sets.neuro=0;
%function that is called when inspecting
sets.posfunc=[];


%merge default sets and stes_user
names=fieldnames(sets);
for i=1:length(names);
    if isfield(sets_user,names{i})
        sets = setfield(sets,names{i},getfield(sets_user,names{i}));
    end
end

% create window
h=figure('BusyAction','cancel',...
    'Color',sets.backgroundcolor,...
    'IntegerHandle','off',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Resize','on',...
    'Position',[20,200,600,650],...
    'tag',mfilename);
    
set(h,'BackingStore',sets.backingstore,'Doublebuffer',sets.doublebuffer);

%set start colormap
colormap(sets.startcmap);

% set name
setName(h,[]);

%set callback for close request
set(h,'CloseRequestFcn',{@doClose,h});

%set callback for delete
set(h,'DeleteFcn',{@doDelete,h});

%set callback for resize
set(h,'ResizeFcn',{@doResize,h});

%set callback for keys
set(h,'KeyPressFcn',{@doKeyPress,h});


%create information frame
frame_h=uicontrol('Style','Frame','Units','normalized',...
    'Position',[0.02,0.92,0.96,0.06],'BackgroundColor',sets.framecolor);

%create axes and images
% empty handles
ax_h=[-1 -1 -1];
im_h=[-1 -1 -1];

%create top menus
files_me_h = uimenu(h,'Label','&File');
views_me_h = uimenu(h,'Label','&View');
tools_me_h = uimenu(h,'Label','&Tools');
link_me_h = uimenu(h,'Label','&Link','Callback',{@doLinkMenu,h});
%windoww menu
uimenu(h, 'Label', '&Window', ...
    'Callback', winmenu('callback'), 'Tag', 'winmenu');
%winmenu(h);  % Initialize the submenu




%file menus
uimenu(files_me_h,'Label','&Open...','Callback',{@doOpenMenu,h});
%duplicate 
uimenu(files_me_h,'Label','&Duplicate Viewer','Callback',{@doDuplicateMenu,h});

uimenu(files_me_h,'Label','Export To &Workspace...','Callback',{@doWorkspaceMenu,h});

%print menu
uimenu(files_me_h,'Label','&Print...','Callback',{@doPrintMenu,h},...
    'Separator','on');
uimenu(files_me_h,'Label','Print Set&up...','Callback',{@doPrintSetupMenu,h});
uimenu(files_me_h,'Label','Print Pre&view...','Callback',{@doPrintPreviewMenu,h});

%close menus
close_me_h=uimenu(files_me_h,'Label','&Close','Separator','on');
uimenu(close_me_h,'Label','Current','Callback',{@doClose,h});
uimenu(close_me_h,'Label','All','Callback',{@doCloseAll,h});

%create colormap menus
colormaps = {'jet','gray','hsv','red','blue','green','hot','bone','copper','pink','white','flag','lines',...
        'colorcube','vga','prism','cool','autumn','spring','winter','summer'};
cmap_me_h = uimenu(views_me_h,'Label','Colormap');
for i=1:length(colormaps)
    %set first character to upper case, and other to lower case
    cm= lower(colormaps{i});
    cm(1)=upper(cm(1));
    cmaps_h(i)=uimenu(cmap_me_h,'Label',cm,'Callback',{@doColormapMenu,h,i});
end
%check olormap if in list
ind = strmatch(sets.startcmap,colormaps);
if ~isempty(ind)
    set(cmaps_h(ind),'Checked','on');
end



%zoom menus
ow_zo_h=uimenu(views_me_h,'Label','Zoom');
own_zoom_me_h=uimenu(ow_zo_h,'Label','Power Zoom','Callback',{@doOwnZoom,h});
own_zoom_linked_me_h=uimenu(ow_zo_h,'Label','Link Power Zoom','Callback',{@doOwnZoomLinked,h});
zoom_me_h=uimenu(ow_zo_h,'Label','Matlab Zoom','Callback',{@doZoom,h},'Separator','on');


planes_me_h=uimenu(views_me_h,'Label','Planes');
plane_me_h(1)=uimenu(planes_me_h,'Label','X','Callback',{@doPlanesMenu,h,1});
if any(sets.viewers==1) set(plane_me_h(1),'Checked','on'); end
plane_me_h(2)=uimenu(planes_me_h,'Label','Y','Callback',{@doPlanesMenu,h,2});
if any(sets.viewers==2) set(plane_me_h(2),'Checked','on'); end
plane_me_h(3)=uimenu(planes_me_h,'Label','Z','Callback',{@doPlanesMenu,h,3});
if any(sets.viewers==3) set(plane_me_h(3),'Checked','on'); end

vox_me_h=uimenu(views_me_h,'Label','Use Voxelsize','Callback',{@doVoxMenu,h},'Separator','on');
if sets.usevoxelsize set(vox_me_h,'Checked','on'); end

%set voxel size
uimenu(views_me_h,'Label','Set Voxelsize...','Callback',{@doSetVoxMenu,h});

% set cross hiars
ax_me_h=uimenu(views_me_h,'Label','Display Axis','Separator','on');
if sets.show_cross
    set(ax_me_h,'Checked','on');
end
set(ax_me_h,'Callback',{@doAxisMenu,h});

% flip along a dimension
flips_me_h = uimenu(views_me_h,'Label','Flip Image');
flip_me_h(1) = uimenu(flips_me_h,'Label','Anterior - Posterior','Callback',{@doFlipMenu,h,1});
set(flip_me_h(1),'Checked','off');
flip_me_h(2)=uimenu(flips_me_h,'Label','Superior - Inferior','Callback',{@doFlipMenu,h,2});
set(flip_me_h(2),'Checked','off');
flip_me_h(3)=uimenu(flips_me_h,'Label','Left - Right','Callback',{@doFlipMenu,h,3});
set(flip_me_h(3),'Checked','off');

% set neuro
ne_me_h=uimenu(views_me_h,'Label','Neurological');
if sets.neuro
    set(ne_me_h,'Checked','on');
end
set(ne_me_h,'Callback',{@doNeuroMenu,h});




%maximum intensity projection
t_h=uimenu(views_me_h,'Label','MIP','Callback',{@doMipMenu,h});
if sets.mip
    set(t_h,'Checked','on');
end

%use of RGB or native
t_h = uimenu(views_me_h,'Label','Use RGB','Callback',{@doUseRGBMenu,h});
%option disabled
set(t_h,'Visible','off');

if sets.RGB
    set(t_h,'Checked','on');
end

%field options menus
field_me_h(1)=uimenu(views_me_h,'Label','Field Color...','Enable','off','Callback',{@doFieldMenu,h},...
    'Separator','on');
field_me_h(2)=uimenu(views_me_h,'Label','Field Scale...','Enable','off','Callback',{@doFieldScaleMenu,h});




%goto menu
goto_me_h=uimenu(tools_me_h,'Label','&Go To');
uimenu(goto_me_h,'Label','M&inimum','Callback',{@doGotoMenu,h,1});
uimenu(goto_me_h,'Label','M&aximum','Callback',{@doGotoMenu,h,2});
uimenu(goto_me_h,'Label','&Value','Callback',{@doGotoMenu,h,3});


%draw menu
t_h=uimenu(tools_me_h,'Label','&Draw');
     draw_rectangle_me_h=uimenu(t_h,'Label','&Draw Rectangle','Callback',{@doDrawRectangleMenu,h});
     draw_freeform_me_h=uimenu(t_h,'Label','&Draw Freeform','Callback',{@doDrawFreeformMenu,h});
     uimenu(t_h,'Label','Draw Value...','Callback',{@doSetValue,h,'drawcolor','Draw color',0});
     block_me_h=uimenu(t_h,'Label','&All Slices','Callback',{@doBlockMenu,h},'Separator','on');


%eval function
eval_h=uimenu(tools_me_h,'Label','&Eval','Callback',{@doEvalMenu,h});
     
D_me_h = uimenu(tools_me_h,'Label','3D');
% 3D slicer
% should be tested and validated
     uimenu(D_me_h,'Label','New &Slicer','Callback',{@do3DSclicerMenu,h});
     uimenu(D_me_h,'Label','New &Isosurface...','Callback',{@do3DMenu,h});
     %figure selector
     uimenu(D_me_h,'Label','Set Add Axes...','Callback',{@doSetAddAxesMenu,h});
%alpha map settings TODO implement
al_me_h = uimenu(D_me_h,'Label','&Transparency Map','Separator','on'); 
      al_ty_me_h(1) = uimenu(al_me_h,'Label','None','Callback',{@doAlphaTypeMenu,h,1});
      al_ty_me_h(2) = uimenu(al_me_h,'Label','Lower Treshold','Callback',{@doAlphaTypeMenu,h,2});
      al_ty_me_h(3) = uimenu(al_me_h,'Label','Higher Threshold','Callback',{@doAlphaTypeMenu,h,3});
      
      al_ty_me_h(4) = uimenu(al_me_h,'Label','Image','Callback',{@doAlphaTypeMenu,h,4});
      set(al_ty_me_h(sets.alphamap),'Checked','on');
      
      uimenu(D_me_h,'Label','Transparency Threshold...','Callback',{@doSetValue,h,'alphathresh','Transparency threshold',1});     
      
%redraw
uimenu(tools_me_h,'Label','Redraw','Callback',{@doRedrawMenu,h});




%link menu
uimenu(link_me_h,'Label','no viewers','Enable','off');


% create text position box
pos_te_h=uicontrol('Style','text','Units','normalized','String','(x,y,z)=val','HorizontalAlignment','right',...
    'Position',[0.56,0.93,0.4,0.03],'BackgroundColor',sets.framecolor);
%create field value position box)
field_te_h=uicontrol('Style','text','Units','normalized','String','(x,y,z)=(u,v,w)','HorizontalAlignment','right',...
    'Position',[0.56,0.93,0.4,0.03],'BackgroundColor',sets.framecolor,'Visible','off');

%create label position text
lab_te_h=uicontrol('Style','text','Units','normalized','String','','HorizontalAlignment','center',...
    'Position',[0.35,0.93,0.3,0.03],'BackgroundColor',sets.framecolor,'Visible','off');

%create plane edit boxes
plane_ed_h(1)=uicontrol('Style','edit','Units','normalized',...
    'Position',[0.07,0.93,0.05,0.04],'HorizontalAlignment','right',...
    'Callback',{@doPlaneEdit,h,1},'BackgroundColor',sets.backgroundcolor);
plane_ed_h(2)=uicontrol('Style','edit','Units','normalized',...
    'Position',[0.17,0.93,0.05,0.04],'HorizontalAlignment','right',...
    'Callback',{@doPlaneEdit,h,2},'BackgroundColor',sets.backgroundcolor);
plane_ed_h(3)=uicontrol('Style','edit','Units','normalized',...
    'Position',[0.27,0.93,0.05,0.04],'HorizontalAlignment','right',...
    'Callback',{@doPlaneEdit,h,3},'BackgroundColor',sets.backgroundcolor);
plane_te_h(1)=uicontrol('Style','text','Units','normalized','String','x','HorizontalAlignment','right',...
    'Position',[0.04,0.93,0.02,0.03],'BackgroundColor',sets.framecolor);
plane_te_h(2)=uicontrol('Style','text','Units','normalized','String','y','HorizontalAlignment','right',...
    'Position',[0.13,0.93,0.02,0.03],'BackgroundColor',sets.framecolor);
plane_te_h(3)=uicontrol('Style','text','Units','normalized','String','z','HorizontalAlignment','right',...
    'Position',[0.24,0.93,0.02,0.03],'BackgroundColor',sets.framecolor);



%create gray value sliders
min_val_tt = 'Minimum value';
max_val_tt = 'Maximum value';
min_val_h=uicontrol('Style','Slider','Units','normalized','Position',[0.02 0.05 0.85 0.03],...
    'BackgroundColor',sets.framecolor,'Callback',{@doValSlider,h,1},...
    'TooltipString', min_val_tt);
max_val_h=uicontrol('Style','Slider','Units','normalized','Position',[0.02 0.01 0.85 0.03],...
    'BackgroundColor',sets.framecolor,'Callback',{@doValSlider,h,2},...
    'Tooltipstring', max_val_tt);
min_val_ed_h=uicontrol('Style','edit','Units','normalized','String','','HorizontalAlignment','right',...
    'Position',[0.89,0.05,0.09,0.03],'Callback',{@doValEdit,h,1},...
    'TooltipString', min_val_tt);
max_val_ed_h=uicontrol('Style','edit','Units','normalized','String','','HorizontalAlignment','right',...
    'Position',[0.89,0.01,0.09,0.03],'Callback',{@doValEdit,h,2},...
    'Tooltipstring', max_val_tt);



% create viewers, axes and images
for i=1:3
    
    ax_h(i)=axes('Parent',h,'Units','normalized',...
        'Visible','off',...
        'HandleVisibility','callback','YDir','reverse','CLimMode','manual');
    % only if not mixer
    cme_h(i)=uicontextmenu;
    
        scale_me_h(i,1)=uimenu(cme_h(i),'Label','Scaling');
        scale_me_h(i,2)=uimenu(scale_me_h(i,1),'Label','Global','Callback',{@doGlobalScale,h});
        scale_me_h(i,3)=uimenu(scale_me_h(i,1),'Label','Manual','Callback',{@doManualScale,h,i});
        %TODO reimplemt other scaling modes, switched off for RGB
        scale_me_h(i,4)=uimenu(scale_me_h(i,1),'Label','Master','Callback',{@doMasterScale,h,i},...
        'Enable','off');
        scale_me_h(i,5)=uimenu(scale_me_h(i,1),'Label','Auto','Callback',{@doAutoScale,h},...
        'Enable','off');
    
    im_h(i)=image('Parent',ax_h(i),'HandleVisibility','callback','XData',1,'YData',1,...
        'CDataMapping','scaled','UIContextMenu',cme_h(i),'Visible','off'); 
    set(im_h(i),'ButtonDownFcn',{@doImageButton,h,im_h(i),ax_h(i),i});
    cross_li_h(i,1)=line('Parent',ax_h(i),'LineWidth',sets.cross_thick,...
            'LineStyle','-.','ButtonDownFcn',{@doImageButton,h,im_h(i),ax_h(i),i},'Visible','off');
    cross_li_h(i,2)=line('Parent',ax_h(i),'LineWidth',sets.cross_thick,...
            'LineStyle','-.','ButtonDownFcn',{@doImageButton,h,im_h(i),ax_h(i),i},'Visible','off');       
end

%disable if ismixer
if sets.ismixer
    set(t_h,'Enable','off');
    set(goto_me_h,'Enable','off');
    set(cmap_me_h,'Enable','off');
    set(min_val_h,'Enable','off');set(max_val_h,'Enable','off');
    set(min_val_ed_h,'Enable','off');set(max_val_ed_h,'Enable','off');
    set(scale_me_h(:),'Enable','off');
    set(al_ty_me_h,'Enable','off');
    set(al_me_h,'Enable','off');
    sets.scaling = 'global';
end



setappdata(h,'Axes',ax_h);
setappdata(h,'Images',im_h);
setappdata(h,'AxisMenu',ax_me_h);
setappdata(h,'ConMenus',cme_h);
setappdata(h,'ScaleMenus',scale_me_h);
setappdata(h,'ZoomMenu',zoom_me_h);
setappdata(h,'OwnZoomMenu',own_zoom_me_h);
setappdata(h,'OwnZoomLinkedMenu',own_zoom_linked_me_h)
setappdata(h,'LinkMenu',tools_me_h);
setappdata(h,'PlaneEdits',plane_ed_h);
setappdata(h,'PlaneTexts',plane_te_h);
setappdata(h,'PlaneMenus',plane_me_h);
setappdata(h,'CrossLines',cross_li_h);
setappdata(h,'PosText',pos_te_h);
setappdata(h,'FieldText',field_te_h);
setappdata(h,'ValSliders',[min_val_h,max_val_h]);
setappdata(h,'ValEdits',[min_val_ed_h max_val_ed_h]);
setappdata(h,'FieldLines',[{[]} {[]} {[]}]);
setappdata(h,'FieldSlicerLines',[{[]} {[]} {[]}]);
setappdata(h,'Slicer',[]);
setappdata(h,'FieldMenu',field_me_h);
setappdata(h,'LabelText',lab_te_h);
setappdata(h,'DrawRectangleMenu',draw_rectangle_me_h);
setappdata(h,'DrawFreeformMenu',draw_freeform_me_h);
setappdata(h,'DrawValueEditor',[]);
setappdata(h,'BlockMenu',block_me_h);
setappdata(h,'VoxMenu',vox_me_h);
setappdata(h,'Frame',frame_h);
setappdata(h,'ColorMaps',colormaps);

%create colormap
if isnumeric(sets.startcmap)
    %directly set array
    setappdata(h,'CMap',sets.startcmap);
else
    %else evaluate 256 colors
    setappdata(h,'CMap',feval(sets.startcmap,256));
end
% set empty link array
setappdata(h,'LinkFigs',[]);

% store general data
setappdata(h,'ViewerSettings',sets);
if nargin==0
    setappdata(h,'CallerHandle',h);
else
   setappdata(h,'CallerHandle',c_h);
end 


%set printer defaults
setPrintDefaults(h);

%initDrawToolbar(h);
return


function setPrintDefaults(h)
% function sets printing to default 
% values

%first get print template
pt = getprinttemplate(h);
if isempty(pt)
  pt = printtemplate;
end
%now set defaults

%do not print user interface
pt.PrintUI=0;
%do use color eps
pt.PrintDriver='psc2';


%set the defaults
set(h, 'PrintTemplate', pt);

%set size to be the same as on screen
set(h,'PaperPositionMode','auto');



%function initDrawToolbar(h)
%function creates invisible toolbar
% for use with draw command
%toolbar_h=uitoolbar(h);

%create drawing toolbar
%setappdata(h,'Toolbar',toolbar_h);
%mode
%mode_h=uitoggletool('CData',rand(16,16,3));



function redrawScaleLines(h,pos)
sets=getappdata(h,'ViewerSettings');
cross_li_h=getappdata(h,'CrossLines');
if any(sets.viewers==1)
    if sets.neuro
        set(cross_li_h(1,1),'XData',[pos(2) pos(2)]);
        set(cross_li_h(1,2),'YData',[pos(3) pos(3)]);
    else
        set(cross_li_h(1,2),'YData',[pos(2) pos(2)]);
        set(cross_li_h(1,1),'XData',[pos(3) pos(3)]);
    end
    
end
if any(sets.viewers==2)
    set(cross_li_h(2,2),'YData',[pos(3) pos(3)]);
    set(cross_li_h(2,1),'XData',[pos(1) pos(1)]);
end
if any(sets.viewers==3)
    set(cross_li_h(3,2),'YData',[pos(2) pos(2)]);
    set(cross_li_h(3,1),'XData',[pos(1) pos(1)]);
end
return

function redrawScaleMenu(h)
% set checkmarks in menus to show scale mode
sets=getappdata(h,'ViewerSettings');
switch sets.scaling
case 'global'
    mo=1;
case 'manual'
    mo=2;
case 'master' 
    mo=3;
case 'auto'
    mo=4;
otherwise
    warning('Unknown scale mode');
end
scale_me_h=getappdata(h,'ScaleMenus');
for i=sets.viewers
    for j=1:4
        set(scale_me_h(i,j+1),'Checked','off');
    end
    if (mo~=3)|(sets.scale_master==i) 
        set(scale_me_h(i,mo+1),'Checked','on');
    else
        set(scale_me_h(i,mo+1),'Checked','off');
    end
end

function redrawAll(h)
% function redraws all planes
sets=getappdata(h,'ViewerSettings');
% set all active viewers ready for redraw
% and call redraw function
redrawPlanes(h,sets.viewers)

function redrawPosition(h,pos,val)
pos_te_h=getappdata(h,'PosText');
%sprintf('(%i,%i,%i)_:_%s value',pos(1),pos(2),pos(3),num2str(val))
set(pos_te_h,'String',sprintf('(%i,%i,%i) : %s ',pos(1),pos(2),pos(3),num2str(val)));
sets=getappdata(h,'ViewerSettings');
%update label if necessary
if sets.labels
    labels=getappdata(h,'Labels');
    val=round(val);
    if (val>0)&(val<=length(labels))
        set(getappdata(h,'LabelText'),'String',labels{val});
    else
        set(getappdata(h,'LabelText'),'String','');
    end
end
%update vector value if possible and existing
if sets.field
    field_te_h=getappdata(h,'FieldText');
    field=getappdata(h,'Field');
    p=find((field.x==pos(1))&(field.y==pos(2))&(field.z==pos(3)));
    if ~isempty(p)
        set(field_te_h,'String',...
            ['[' num2str(field.u(p)) ',' num2str(field.v(p)) ',' num2str(field.w(p)) '] ']);
    else
       set(field_te_h,'String','No vector');
   end
end
return


function out_im=applyColormap(h,in_im)
%function apllies colormap to indexed image and returns RGB image
c_map=get(h, 'Colormap');
mi=min(in_im(:));
ma=max(in_im(:));
if mi==ma
    ma=mi+1;
end
in_im=round(1+(size(c_map,1)-1)*((in_im-mi)/(ma-mi)));
in_im(in_im<1)=1;
in_im(in_im>size(c_map,1))=size(c_map,1);
out_im=zeros(size(in_im,1),size(in_im,2),3);
out_im(:,:,1)=reshape(c_map(in_im(:),1),size(in_im,1),size(in_im,2));
out_im(:,:,2)=reshape(c_map(in_im(:),2),size(in_im,1),size(in_im,2));
out_im(:,:,3)=reshape(c_map(in_im(:),3),size(in_im,1),size(in_im,2));
return

function redrawPlanes(h,viewers,link_h)
% redraw planes as selected by viewers
sets=getappdata(h,'ViewerSettings');
ima=getappdata(h,'Image');
im_h=getappdata(h,'Images');
ax_h=getappdata(h,'Axes');
plane_ed_h=getappdata(h,'PlaneEdits');
%only load fields in variables if needed
if sets.field
    field=getappdata(h,'Field');
    field_lines=getappdata(h,'FieldLines');
    field_slicer_lines=getappdata(h,'FieldSlicerLines');
end


%very dirty hack for slicer
%TODO cache planes
if sets.slicer&sets.alphamap>1
    %serves to not force a total redraw to viewers who do not need it
    viewers_local=1:3;
else
    viewers_local =viewers;
end


for i=viewers_local
    %set(plane_ed_h(i),'String',num2str(sets.plane(i)));
    set(plane_ed_h(i),'String',sprintf('%i',sets.plane(i)));
    %redraw classic plane for no mixer
    if ~sets.ismixer
        if sets.mip
            %mip plnae mode
            switch i
            case 1
                plane=shiftdim(squeeze(max(ima,[],1))',1);
            case 2
                plane=squeeze(max(ima,[],2))';
                %fprintf('(%i,%i)-(%i,%i)\n',size(plane,1),size(plane,2),sets.plane(3),sets.plane(1));
            case 3
                plane=squeeze(max(ima,[],3))';
                %fprintf('(%i,%i)-(%i,%i)\n',size(plane,1),size(plane,2),sets.plane(1),sets.plane(2));
            end
        else
%             if sets.RGB
%                 [plane,sli] = getSlice(ima,i,sets.plane(i),getappdata(h,'CMap'),sets.clim(i,:),1);
%             else
%                 plane = getSlice(ima,i,sets.plane(i),getappdata(h,'CMap'),sets.clim(i,:),2);
%                 sli=plane;
%             end 
            %alternative non rgb code
            %normal plane mode
            switch i
            case 1
                if ndims(ima)==2
                    plane=ima(sets.plane(i),:)';
                else
                    plane=shiftdim(squeeze(ima(sets.plane(i),:,:))',1);
                end
                %fprintf('(%i,%i)-(%i,%i)\n',size(plane,1),size(plane,2),sets.plane(2),sets.plane(3));
            case 2
                plane=squeeze(ima(:,sets.plane(i),:))';
                %fprintf('(%i,%i)-(%i,%i)\n',size(plane,1),size(plane,2),sets.plane(3),sets.plane(1));
            case 3
                plane=ima(:,:,sets.plane(i))';
                %fprintf('(%i,%i)-(%i,%i)\n',size(plane,1),size(plane,2),sets.plane(1),sets.plane(2));
            end
        end
        
        
        % do master scaling
        if strcmp(sets.scaling,'master')&(i==sets.scale_master)
            
            % find min and max
            mi=min(plane(:));
            ma=max(plane(:));
            if mi==ma
                ma=mi+1;
            end
            %set values for all viewers
            %for j=sets.viewers
            %    set(ax_h(j),'CLim',[mi ma]);
            %end
            setCLim(h,[1:3],[mi ma]);
        end

        %set image
        %set(im_h(i),'CData',plane);                        
    else %draw if mixer
        plane = imagemixer(sets.mixer,i,sets.plane(i));
        %set(im_h(i),'CData',plane);
    end
    if i==1&sets.neuro
        %turn image
        plane_ex=permute(plane,[2 1 3]);
        set(im_h(i),'CData',plane_ex); 
    else
        %set image
        set(im_h(i),'CData',plane);   
    end
    
    %if slicer
    if sets.slicer
        imsize = getappdata(h,'imsize');
        sli_h=getappdata(h,'Slicer');
        pa_hs=getappdata(h,'SliSurf');
        %check that figure still exists
        
        if all(ishandle(pa_hs))
            switch i
            case 1
                %set(pa_hs(i,1),'Xdata',repmat(sets.plane(i),2,2),'YData',repmat([0.5 imsize(2)+0.5],2,1),'ZData',...
                %     [0.5 0.5 ;imsize(3)+0.5 imsize(3)+0.5 ],'CData',plane,'Visible','on');
                plane = permute(plane,[ 2 1 3]);
                sli=plane;
                if (sets.plane(2)>1)&(sets.plane(3)>1)
                    set(pa_hs(i,1),'Xdata',repmat(sets.plane(i),2,2),'YData',repmat([0.5 sets.plane(2)+0.5],2,1),'ZData',...
                        [0.5 0.5 ;sets.plane(3)+0.5 sets.plane(3)+0.5 ],'CData',plane(1:sets.plane(3),1:sets.plane(2),:),'Visible','on');
                else
                    set(pa_hs(i,1),'Visible','off'); 
                end
                if (sets.plane(2)<imsize(2))&(sets.plane(3)>1)
                    set(pa_hs(i,2),'Xdata',repmat(sets.plane(i),2,2),'YData',repmat([sets.plane(2)-0.5 imsize(2)+0.5],2,1),'ZData',...
                        [0.5 0.5 ;sets.plane(3)+0.5 sets.plane(3)+0.5 ],'CData',plane(1:sets.plane(3),sets.plane(2):end,:),'Visible','on');
                else
                    set(pa_hs(i,2),'Visible','off'); 
                end                
                if (sets.plane(2)>1)&(sets.plane(3)<imsize(3))
                    set(pa_hs(i,3),'Xdata',repmat(sets.plane(i),2,2),'YData',repmat([0.5 sets.plane(2)+0.5],2,1),'ZData',...
                        [sets.plane(3)-0.5 sets.plane(3)-0.5;imsize(3)+0.5 imsize(3)+0.5 ],...
                        'CData',plane(sets.plane(3):end,1:sets.plane(2),:),'Visible','on');
                else
                    set(pa_hs(i,3),'Visible','off'); 
                end                
                if (sets.plane(2)<imsize(2))&(sets.plane(3)<imsize(3))
                    set(pa_hs(i,4),'Xdata',repmat(sets.plane(i),2,2),'YData',repmat([sets.plane(2)-0.5 imsize(2)+0.5],2,1),'ZData',...
                        [sets.plane(3)-0.5 sets.plane(3)-0.5;imsize(3)+0.5 imsize(3)+0.5 ],...
                        'CData',plane(sets.plane(3):end,sets.plane(2):end,:),'Visible','on');
                else
                    set(pa_hs(i,4),'Visible','off'); 
                end
            case 2
                %set(pa_hs(i,1),'Ydata',repmat(sets.plane(i),2,2),'XData',[0.5 imsize(1)+0.5;0.5 imsize(1)+0.5 ],'ZData',...
                %        [0.5 0.5; imsize(3)+0.5 imsize(3)+0.5],'CData',plane);
                if (sets.plane(1)>1)&(sets.plane(3)>1)
                    set(pa_hs(i,1),'Ydata',repmat(sets.plane(i),2,2),'XData',repmat([0.5 sets.plane(1)+0.5],2,1),'ZData',...
                        [0.5 0.5; sets.plane(3)+0.5 sets.plane(3)+0.5],'CData',plane(1:sets.plane(3),1:sets.plane(1),:),'Visible','on');
                else
                    set(pa_hs(i,1),'Visible','off'); 
                end
                if (sets.plane(1)<imsize(1))&(sets.plane(3)>1)
                    set(pa_hs(i,2),'Ydata',repmat(sets.plane(i),2,2),'XData',repmat([sets.plane(1)-0.5 imsize(1)+0.5],2,1),'ZData',...
                        [0.5 0.5; sets.plane(3)+0.5 sets.plane(3)+0.5],'CData',plane(1:sets.plane(3),sets.plane(1):end,:),'Visible','on');
                else
                    set(pa_hs(i,2),'Visible','off'); 
                end
                if (sets.plane(1)>1)&(sets.plane(3)<imsize(3))
                    set(pa_hs(i,3),'Ydata',repmat(sets.plane(i),2,2),'XData',repmat([0.5 sets.plane(1)+0.5],2,1),'ZData',...
                        [sets.plane(3)-0.5 sets.plane(3)-0.5;imsize(3)+0.5 imsize(3)+0.5],...
                        'CData',plane(sets.plane(3):end,1:sets.plane(1),:),'Visible','on');
                else
                    set(pa_hs(i,3),'Visible','off'); 
                end
                if (sets.plane(1)<imsize(1))&(sets.plane(3)<imsize(3))
                    set(pa_hs(i,4),'Ydata',repmat(sets.plane(i),2,2),'XData',repmat([sets.plane(1)-0.5 imsize(1)+0.5],2,1),'ZData',...
                        [sets.plane(3)-0.5 sets.plane(3)-0.5;imsize(3)+0.5 imsize(3)+0.5],...
                        'CData',plane(sets.plane(3):end,sets.plane(1):end,:),'Visible','on');
                else
                    set(pa_hs(i,4),'Visible','off'); 
                end
                
            case 3
                %set(pa_hs(i),'Zdata',repmat(sets.plane(i),2,2),'XData',[0.5 imsize(1)+0.5;0.5 imsize(1)+0.5 ],'YData',...
                %    [0.5 0.5; imsize(2)+0.5 imsize(2)+0.5],'CData',plane);
                if all(sets.plane(1:2)>1)
                    set(pa_hs(i,1),'Zdata',repmat(sets.plane(i),2,2),'XData',repmat([0.5 sets.plane(1)+0.5],2,1),'YData',...
                        [0.5 0.5;sets.plane(2)+0.5 sets.plane(2)+0.5],'CData',plane(1:sets.plane(2),1:sets.plane(1),:),'Visible','on');
                else
                    set(pa_hs(i,1),'Visible','off'); 
                end
                if (sets.plane(1)<imsize(1))&(sets.plane(2)>1)
                    set(pa_hs(i,2),'Zdata',repmat(sets.plane(i),2,2),'XData',repmat([sets.plane(1)-0.5 imsize(1)+0.5 ],2,1),'YData',...
                        [0.5 0.5;sets.plane(2)+0.5 sets.plane(2)+0.5],'CData',plane(1:sets.plane(2),sets.plane(1):end,:),'Visible','on');
                else
                    set(pa_hs(i,2),'Visible','off'); 
                end                
                if (sets.plane(1)>1)&(sets.plane(2)<imsize(2))
                    set(pa_hs(i,3),'Zdata',repmat(sets.plane(i),2,2),'XData',repmat([0.5 sets.plane(1)+0.5 ],2,1),'YData',...
                        [sets.plane(2)-0.5 sets.plane(2)-0.5; imsize(2)+0.5 imsize(2)+0.5],...
                        'CData',plane(sets.plane(2):end,1:sets.plane(1),:),'Visible','on');
                else
                    set(pa_hs(i,3),'Visible','off'); 
                end
                if (sets.plane(1)<imsize(1))&(sets.plane(2)<imsize(2))
                    set(pa_hs(i,4),'Zdata',repmat(sets.plane(i),2,2),'XData',repmat([sets.plane(1)-0.5 imsize(1)+0.5],2,1),'YData',...
                        [sets.plane(2)-0.5 sets.plane(2)-0.5; imsize(2)+0.5 imsize(2)+0.5],...
                        'CData',plane(sets.plane(2):end,sets.plane(1):end,:),'Visible','on');
                else
                    set(pa_hs(i,4),'Visible','off'); 
                end
            end
            %set alphamap
           
            switch sets.alphamap
            case 1
                %do nothing
            case 2
                if sets.RGB
                    plane=sli;
                end                
                alpha = plane<sets.alphathresh;
             case 3
                if sets.RGB
                    plane=sli;
                end
                alpha = plane>sets.alphathresh;
             case 4
                if sets.RGB
                    plane=sli;
                end
                alpha = plane;   
            end
           
            if sets.alphamap>1
                switch i
                case 3
                    if all(sets.plane(1:2)>1)
                        set(pa_hs(3,1),'AlphaData',alpha(1:sets.plane(2),1:sets.plane(1)));
                    end
                    if (sets.plane(1)<imsize(1))&(sets.plane(2)>1)
                        set(pa_hs(3,2),'AlphaData',alpha(1:sets.plane(2),sets.plane(1):end));
                    end
                    if (sets.plane(1)>1)&(sets.plane(2)<imsize(2))
                        set(pa_hs(3,3),'AlphaData',alpha(sets.plane(2):end,1:sets.plane(1)));
                    end
                    if (sets.plane(1)<imsize(1))&(sets.plane(2)<imsize(2))
                        set(pa_hs(3,4),'AlphaData',alpha(sets.plane(2):end,sets.plane(1):end));
                    end                
                case 2
                    if (sets.plane(1)>1)&(sets.plane(3)>1)
                        set(pa_hs(2,1),'AlphaData',alpha(1:sets.plane(3),1:sets.plane(1)));
                    end
                    if (sets.plane(1)<imsize(1))&(sets.plane(3)>1)
                        set(pa_hs(2,2),'AlphaData',alpha(1:sets.plane(3),sets.plane(1):end));
                    end
                    if (sets.plane(1)>1)&(sets.plane(3)<imsize(3))
                        set(pa_hs(2,3),'AlphaData',alpha(sets.plane(3):end,1:sets.plane(1)));
                    end
                    if (sets.plane(1)<imsize(1))&(sets.plane(3)<imsize(3))
                        set(pa_hs(2,4),'AlphaData',alpha(sets.plane(3):end,sets.plane(1):end));
                    end
                case 1
                    if (sets.plane(2)>1)&(sets.plane(3)>1)
                        set(pa_hs(1,1),'AlphaData',alpha(1:sets.plane(3),1:sets.plane(2)));                
                    end
                    if (sets.plane(2)<imsize(2))&(sets.plane(3)>1)
                        set(pa_hs(1,2),'AlphaData',alpha(1:sets.plane(3),sets.plane(2):end));               
                    end                
                    if (sets.plane(2)>1)&(sets.plane(3)<imsize(3))
                        set(pa_hs(1,3),'AlphaData',alpha(sets.plane(3):end,1:sets.plane(2)));               
                    end                
                    if (sets.plane(2)<imsize(2))&(sets.plane(3)<imsize(3))
                        set(pa_hs(1,4),'AlphaData',alpha(sets.plane(3):end,sets.plane(2):end));             
                    end
                end
            end
            %take care of refesh bug
            % matlab does not refresh if only alpha changes
            set(pa_hs,'AlphaDataMapping','none');
            set(pa_hs,'AlphaDataMapping','scaled');
        else
             %unconnect to 3D slice figure
            sets.slicer=0;
            setappdata(h,'FieldSlicerLines',[{[]} {[]} {[]}]);
            setappdata(h,'ViewerSettings',sets);
        end
    end    
    
    
    
end
if ~sets.ismixer
    redrawPosition(h,sets.plane,ima(sets.plane(1),sets.plane(2),sets.plane(3)));
end
    
   


if sets.show_cross
    redrawScaleLines(h,sets.plane)
end


% if field and prevent drawing when axes handles are not accessible, I dont understand buut it works
if sets.field&length(findobj(h,'Type','axes'))>2
    for i=viewers
        % first delete old field
        delete(field_lines{i});
        set(h,'NextPlot','add');
        set(ax_h(i),'NextPlot','add');
        set(h,'CurrentAxes',ax_h(i));
        switch i
        case 1  
            vu=find(field.x==sets.plane(i));
            if any(vu)
                field_lines{i}=my_quiver(field.z(vu),field.y(vu),field.w(vu),field.v(vu),...
                    sets.fieldscale,ax_h(i));
            else
                field_lines{i}=[];
            end
        case 2
            vu=find(field.y==sets.plane(i));
            if any(vu)
                field_lines{i}=my_quiver(field.x(vu),field.z(vu),field.u(vu),field.w(vu),...
                    sets.fieldscale,ax_h(i));
            else
                field_lines{i}=[];
            end
        case 3
            vu=find(field.z==sets.plane(i));
            if any(vu)
                field_lines{i}=my_quiver(field.x(vu),field.y(vu),field.u(vu),field.v(vu),...
                    sets.fieldscale,ax_h(i));
            else
                field_lines{i}=[];
            end
        end
        set(field_lines{i},'ButtonDownFcn',{@doImageButton,h,im_h(i),ax_h(i),i},'Color',sets.fieldcolor);
        %if 3D slicer
        if sets.slicer
            sli_ax_h=getappdata(h,'SliAxes');
            delete(field_slicer_lines{i});
            if any(vu)
                %&ishandle(sli_ax_h);
                %set(getappdata(h,'SliAxes'),'NextPlot','add');
                field_slicer_lines{i}=my_quiver3(field.x(vu),field.y(vu),field.z(vu),field.u(vu),field.v(vu),field.w(vu),...
                    sets.fieldscale,sli_ax_h);
                set(field_slicer_lines{i},'Color',sets.fieldcolor);
            else
                field_slicer_lines{i}=[];
            end
        end        
    end
    setappdata(h,'FieldLines',field_lines);
    setappdata(h,'FieldSlicerLines',field_slicer_lines);
end
    
% process linked images
% but only if called in master mode
if (nargin==2)&(~isempty(getappdata(h,'LinkFigs')))
    % first update main figure
    %drawnow;
    % make sure all links are OK
    checkLinks(h);
    linkfigs=getappdata(h,'LinkFigs');
    %process all linked images
    for i=linkfigs
        l_sets=getappdata(i,'ViewerSettings');
        % make copy for case of failure
        c_sets=l_sets;
        l_sets.plane=sets.plane;
        setappdata(i,'ViewerSettings',l_sets);
        % try if redraw works
        try
            redrawPlanes(i,viewers,h)
        catch
            %thing got messy...
            warning(sprintf('Invalid linking',get(i,'Name')));
            setappdata(i,'ViewerSettings',c_sets);
            redrawPlanes(i,c_sets.viewers,h);
            % link does not work, so remove link
            % doRemLink([],[],h,i);
        end
    end
end
    

function setName(h,name)
% prevent viewers with the same name
% appends number to end of viewer name
set(0,'ShowHiddenhandles','on');
s_h=setdiff(findobj('tag',get(h,'tag')),h);
set(0,'ShowHiddenhandles','off');
a=[];
if isempty(name)
    name='Viewer';
end
for i=s_h'
    %make sure to only look for tag in figures
    if strcmp(get(i,'Type'),'figure')
        na=getappdata(i,'Name');
        if strcmp(name,na)
            a=[a i];
        end
    end
end
if isempty(a)
    set(h,'Name',name);
else
    if length(a)==1
        set(a,'Name',[name ' (' num2str(length(a)) ')']);
    end
    set(h,'Name',[name ' (' num2str(length(a)+1) ')']);  
end
setappdata(h,'Name',name);


function setNewField(h,field)
setappdata(h,'Field',field);
set(getappdata(h,'FieldText'),'visible','on');
set(getappdata(h,'FieldMenu'),'Enable','on');


function setNewImage(h,ima)
% sets all that is necessary when changing image
setappdata(h,'Image',ima);
sets=getappdata(h,'ViewerSettings');
imsize=size(ima);
%if two dimensional image (that is z=1)
%only show Z plane
if ndims(ima)<3
    imsize(3)=1;
    sets.viewers=3;
    setappdata(h,'ViewerSettings',sets);
   
end
setappdata(h,'imsize',imsize);
%create standard header if no header provided
if sets.header==0
    header.vx=1;
    header.vy=1;
    header.vz=1;
    setappdata(h,'Header',header);
end
doPlanesSwitch(h);
setAxesPositions(h);
setImageInAxes(h);

% settings for global scaling
switch sets.scaling
case 'global'
    doGlobalScale([],[],h);
case 'manual'
    %first do mglobal and the manual
    doGlobalScale([],[],h); 
    doManualScale([],[],h,sets.viewers(1));
end
return


function doAxisMenu(ax_me_h,dev,h)
sets=getappdata(h,'ViewerSettings');
sets.show_cross=1-sets.show_cross;
setappdata(h,'ViewerSettings',sets);
cross_li_h=getappdata(h,'CrossLines');
if sets.show_cross
    set(ax_me_h,'Checked','on');
    set(cross_li_h(:),'Visible','on');
else
    set(ax_me_h,'Checked','off');
    set(cross_li_h(:),'Visible','off');
end
doPlanesSwitch(h);




function doLinkMenu(link_me_h,dev,h)
% create dynamic menu with name of other viewers
%get hanldes off all other viewers
set(0,'ShowHiddenhandles','on');
v_h=findobj('tag',get(h,'tag'));
set(0,'ShowHiddenhandles','off');
%remove itself
v_h=setdiff(v_h,h);
sub_me_h=get(link_me_h,'Children');
% if no compatible viewers
if isempty(v_h)
    %delete all
    %delete(sub_me_h);
    %uimenu(link_me_h,'Label','Unlink');
    %uimenu(link_me_h,'Lable','Link All');
    %uimenu(link_me_h,'Label','none','Enable','off','Separator','on');
    set(sub_me_h(1),'Label','no viewers','Enable','off');
    delete(sub_me_h(2:end));
else
    % never delete first object, MATLAB crashes
    set(sub_me_h(1),'Label',get(v_h(1),'Name'),'Enable','on','Callback',{@doAddLink,h,v_h(1)});
    linkfigs=getappdata(v_h(1),'LinkFigs');
    if (~isempty(linkfigs))&any(linkfigs==h)
        set(sub_me_h(1),'Checked','on','Callback',{@doRemLink,h,v_h(1)});
    else
        set(sub_me_h(1),'Checked','off');
    end
    delete(sub_me_h(2:end));
    for i=2:length(v_h)
        m_h=uimenu(link_me_h,'Label',get(v_h(i),'Name'),'Enable','on','Callback',{@doAddLink,h,v_h(i)});
        linkfigs=getappdata(v_h(i),'LinkFigs');
        if (~isempty(linkfigs))&any(linkfigs==h)
            set(m_h,'Checked','on','Callback',{@doRemLink,h,v_h(i)});
        end
    end
end

function doAddLink(m,dev,h1,h2)
% function creates link between viewers with handles h1 and h2
% function does not check if h1 and h2 exists

% start by getting links
l1=getappdata(h1,'LinkFigs');
l2=getappdata(h2,'LinkFigs');
% merge links
l=unique([l1,l2,h1,h2]);
% keep only valid handles
l=l(ishandle(l));
% set links up to date for all viewers
for i=l
    setappdata(i,'LinkFigs',setdiff(l,i));
end
redrawAll(h1);
return

function doRemLink(m,dev,h1,h2)
% remove h2 of link list
% function does not check if h1 and h2 exists

% start by getting links
l1=getappdata(h1,'LinkFigs');

%remove h2
l=[h1,setdiff(l1,h2)];
%keep only valid handles
l=l(ishandle(l));
% set links up to date for all viewers
for i=l
    setappdata(i,'LinkFigs',setdiff(l,i));
end
setappdata(h2,'LinkFigs',[]);
return

function checkLinks(h)
% check links for validity
% and remove bad links
l=getappdata(h,'LinkFigs');
if ~isempty(l)
    u=ishandle(l);
    % only update if needed
    if any(u==0)
        l=[h,l(u)];
        for i=l
            setappdata(i,'LinkFigs',setdiff(l,i));
        end
    end
end




function doGlobalScale(m,dev,h);
%set scale to global
sets=getappdata(h,'ViewerSettings');
sets.scaling='global';
ima=getappdata(h,'Image');
mi = min(ima(:));
ma  =max(ima(:));
% maximum must always be larger than minimum
if mi==ma
    ma=mi+1;
end
setappdata(h,'ViewerSettings',sets);
setCLim(h,1:3,[mi,ma]);
set(getappdata(h,'ValSliders'),'Enable','off');
set(getappdata(h,'ValEdits'),'Enable','off');
redrawScaleMenu(h);
return
%OLD no RGB code
sets.min_scale=min(ima(:));
sets.max_scale=max(ima(:));
% set different values if image is empty
if sets.min_scale==sets.max_scale;
    sets.max_scale=sets.max_scale+1;
end
% update all viwers
ax_h=getappdata(h,'Axes');
for i=sets.viewers
    set(ax_h(i),'Clim',[sets.min_scale sets.max_scale]);
end
setappdata(h,'ViewerSettings',sets);
set(getappdata(h,'ValSliders'),'Enable','off');
set(getappdata(h,'ValEdits'),'Enable','off');
redrawScaleMenu(h);
return

function doMasterScale(m,dev,h,viewer)
sets=getappdata(h,'ViewerSettings');
sets.scaling='master';
sets.scale_master=viewer;
setappdata(h,'ViewerSettings',sets);
% limits update is implemented in redraw
% function
set(getappdata(h,'ValSliders'),'Enable','off');
set(getappdata(h,'ValEdits'),'Enable','off');
redrawScaleMenu(h);
redrawAll(h);
return

function doManualScale(m,dev,h,viewer)
% set to manual scaling,
sets=getappdata(h,'ViewerSettings');
sets.scaling='manual';
if ~isempty(sets.viewers)
    clim=sets.clim(sets.viewers(1),:);
else
    clim=sets.clim(1,:)
end
val_sli_h=getappdata(h,'ValSliders');
val_ed_h=getappdata(h,'ValEdits');
set(val_sli_h,'Min',clim(1),'Max',clim(2),'Enable','on');
set(val_ed_h(1),'String',num2str(clim(1)),'Enable','on');
set(val_ed_h(2),'String',num2str(clim(2)),'Enable','on');
set(val_sli_h(1),'Value',clim(1));
set(val_sli_h(2),'Value',clim(2));
setappdata(h,'ViewerSettings',sets);
redrawScaleMenu(h);
redrawAll(h);
return

%OLD no RGB code
ax_h=getappdata(h,'Axes');
for i=sets.viewers
    set(ax_h(i),'ClimMode','manual');
end
for i=setdiff(sets.viewers,viewer)
    %set(ax_h(i),'CLim',get(ax_h(viewer),'CLim'));
    setCLim(h,i,get(ax_h(viewer),'CLim'));
end
val_sli_h=getappdata(h,'ValSliders');
clim=get(ax_h(viewer),'CLim');
image=getappdata(h,'Image');
mi=min(image(:));
ma=max(image(:));
if mi==ma
    ma=mi+1;
end

return

function doAutoScale(m,dev,h)
% each viewer is scaled automatically
sets=getappdata(h,'ViewerSettings');
sets.scaling='auto';
% update all viwers
ax_h=getappdata(h,'Axes');
for i=sets.viewers
    set(ax_h(i),'ClimMode','auto');
end
set(getappdata(h,'ValSliders'),'Enable','off');
set(getappdata(h,'ValEdits'),'Enable','off');
setappdata(h,'ViewerSettings',sets);
redrawScaleMenu(h);
return

function doColormapMenu(a,dev,h,i)
%function processes colormap call
colormaps=getappdata(h,'ColorMaps');
%uncheck all
set(get(get(a,'Parent'),'Children'),'checked','off');
set(a,'checked','on');
%finally store colormap
cm = feval(colormaps{i},256);
setappdata(h,'CMap',cm);
%set it to axes for native mode
set(h,'Colormap',cm);
%and redraw all
sets=getappdata(h,'ViewerSettings');
if sets.RGB
    redrawAll(h);
else
    if sets.slicer
        sli_h = getappdata(h,'Slicer');
        if ishandle(sli_h)
            set(getappdata(h,'Slicer'),'Colormap',cm);
        end
    end
end


function setCLim(h,ax,clim)
sets=getappdata(h,'ViewerSettings');
sets.clim(ax,:)=repmat(clim,length(ax),1);
setappdata(h,'ViewerSettings',sets);
%some code if not evrything is RGB
ax_h=getappdata(h,'Axes');
set(ax_h(ax),'Clim',clim); 


    
%redraw necessary for RGB
if sets.RGB
    redrawAll(h);
else
    if sets.slicer
        sli_ax_h = getappdata(h,'SliAxes');
        %check that slicer still exists
        if ishandle(sli_ax_h)
            set(sli_ax_h,'CLim',clim);
        end
    end 
end

return
%OLD non RGB code
%function sets values of intensit
% mappings of all needed axes
ax_h=getappdata(h,'Axes');
set(ax_h(ax),'Clim',clim); 
sets=getappdata(h,'ViewerSettings');
%set values for slicer
if sets.slicer
    sli_ax_h = getappdata(h,'SliAxes');
    %check that slicer still exists
    if ishandle(sli_ax_h)
        set(sli_ax_h,'CLim',clim);
    end
end

function doValSlider(slider,dev,h,sl)
% set changes of colormapping for sliders
% sl defines min or max is changed
ax_h=getappdata(h,'Axes');
sets=getappdata(h,'ViewerSettings');
% get original values
%clim=get(ax_h(1),'Clim');
clim=sets.clim(1,:);
% change value 
val=get(slider,'Value');
%check if min is not larger than max
if ((sl==1)&(val>=clim(2))|((sl==2)&(val<=clim(1))))
    set(slider,'Value',clim(sl));
else
    clim(sl)=get(slider,'Value');
    %set right value
    %set(ax_h,'Clim',clim);    
    setCLim(h,[1:3],clim);
    val_ed_h=getappdata(h,'ValEdits');
    set(val_ed_h(sl),'String',num2str(clim(sl)));
end

function doValEdit(ed_h,dev,h,ed)
% set changes of colormapping for sliders
% sl defines min or max is changed
ax_h=getappdata(h,'Axes');
sets=getappdata(h,'ViewerSettings');
% get original values
%clim=get(ax_h(1),'Clim');
clim=sets.clim(1,:);
% change value 
val=str2num(get(ed_h,'String'));

%check for valid limits, if not then
% enlarge slider reach
val_sl_h=getappdata(h,'ValSliders');
if val>get(val_sl_h(ed),'Max')
    set(val_sl_h(ed),'Max',val);
end
if val<get(val_sl_h(ed),'Min')
    set(val_sl_h(ed),'Min',val);
end
%set right value
clim(ed)=val;
%set(ax_h,'Clim',clim); 
setCLim(h,[1:3],clim);   
val_sl_h=getappdata(h,'ValSliders');
set(val_sl_h(ed),'Value',val);
set(ed_h,'String',num2str(val));
return
%%%%%% OLD code %%%%%%%%%%%%%
%check if min is not larger than max
if ((ed==1)&(val>=clim(2))|((ed==2)&(val<=clim(1))))
    set(ed_h,'String',num2str(clim(ed)));
else
    %set right value
    clim(ed)=val;
    set(ax_h,'Clim',clim);    
    val_sl_h=getappdata(h,'ValSliders');
    set(val_sl_h(ed),'Value',val);
    set(ed_h,'String',num2str(val));
end
%%%%%%%%%%% end of old CODE %%%%%%%%%%%

function setImageInAxes(h)
%funstion set to default zoom factor 1
% sets images to right places in axes
%set image sizes first process general info
sets=getappdata(h,'ViewerSettings');
ax_h=getappdata(h,'Axes');
cross_li_h=getappdata(h,'CrossLines');
imsize=getappdata(h,'imsize');
if any(sets.viewers==1)
    if sets.neuro
        set(ax_h(1),...
            'XLim',[0.5 imsize(2)+0.5],'YLim',[0.5 imsize(3)+0.5]);
        set(cross_li_h(1,1),'YData',get(ax_h(1),'YLim'));
        set(cross_li_h(1,2),'XData',get(ax_h(1),'XLim'));
    else
        set(ax_h(1),...
            'XLim',[0.5 imsize(3)+0.5],'YLim',[0.5 imsize(2)+0.5]);
        set(cross_li_h(1,2),'XData',get(ax_h(1),'XLim'));
        set(cross_li_h(1,1),'YData',get(ax_h(1),'YLim'));
        
    end
end
if any(sets.viewers==2)
    set(ax_h(2),...
        'XLim',[0.5 imsize(1)+0.5],'YLim',[0.5 imsize(3)+0.5]);
    set(cross_li_h(2,2),'XData',get(ax_h(2),'XLim'));
    set(cross_li_h(2,1),'YData',get(ax_h(2),'YLim'));
end
if any(sets.viewers==3)
    set(ax_h(3),...
        'XLim',[0.5 imsize(1)+0.5],'YLim',[0.5 imsize(2)+0.5]);
    set(cross_li_h(3,2),'XData',get(ax_h(3),'XLim'));
    set(cross_li_h(3,1),'YData',get(ax_h(3),'YLim'));
end
%set zoom factor back to one
sets.own_zoom_factor=1;
setappdata(h,'ViewerSettings',sets);


function setAxesPositions(h)
%start by getting window size
set(h,'Units','Pixels');
pos=get(h,'Position');
sets=getappdata(h,'ViewerSettings');
imsize=getappdata(h,'imsize');

if sets.usevoxelsize
    he=getappdata(h,'Header');
else
    he.vx=1;
    he.vy=1;
    he.vz=1;
end

%if slicer
if sets.slicer
    set(getappdata(h,'SliAxes'),'DataAspectRatio',[1/he.vx 1/he.vy 1/he.vz],...
        'XLim',[0.5 imsize(1)+0.5], 'YLim',[0.5 imsize(2)+0.5],'ZLim',[0.5 imsize(3)+0.5]);
end

%GUI has fixed size in pixels
%remaining pixels are used for images

%vertical offset of border
v_off=10;
%horizontal offset from border
h_off=10;
%slider height
v_sl=20;
%text width of intensity sliders
h_in_te=75;
%frame height
v_fr=40;
%offset of frqme border
v_int=10;
%width of plane boxes
h_pl=30;
%width of position text
h_po=200;

%variable of offset above images
ver_rem=0;

%variable of offset under images
ver_of=0;

val_sl_h=getappdata(h,'ValSliders');
val_ed_h=getappdata(h,'ValEdits');
frame_h=getappdata(h,'Frame');
plane_ed_h=getappdata(h,'PlaneEdits');
plane_te_h=getappdata(h,'PlaneTexts');
pos_te_h=getappdata(h,'PosText');
field_te_h=getappdata(h,'FieldText');
lab_te_h=getappdata(h,'LabelText');

ax_h=getappdata(h,'Axes');
cross_li_h=getappdata(h,'CrossLines');

%calculate reamaining image size
ver_of = 3*v_off+2*v_sl; 
ver_rem=2*v_off+v_fr;

%first get size of figure
%neuro convention
if sets.neuro==1
    if any(sets.viewers==3)&(any(sets.viewers==1)|any(sets.viewers==2))
        v_avail=pos(4)-ver_rem-ver_of-v_off;
    else
        v_avail=pos(4)-ver_rem-ver_of;
    end

%    if any(sets.viewers==1)&any(sets.viewers==2)
 %       h_w=imsize(1)*he.vx*2;
 %  else
 %       h_w=imsize(1)*he.vx;
 %  end
   h_w=imsize(1)*he.vx*(any(sets.viewers==2)|any(sets.viewers==3))+...
       any(sets.viewers==1)*imsize(2)*he.vy;
   if ~(any(sets.viewers==2))&any(sets.viewers==1)&any(sets.viewers==3)
       h_w=max(imsize(1)*he.vx,imsize(2)*he.vy);
   end
 
    %if ~any(sets.viewers==1)
    %    if any(sets.viewers==2)
    %        h_w=max(imsize(3)*he.vz,imsize(1)*he.vx);
    %    else
   %         h_w=imsize(3)*he.vz;
   %     end
   %else
  %      h_w=imsize(1)*he.vx+any(sets.viewers==2)*imsize(1)*he.vx;
  %end
    v_w=imsize(3)*(any(sets.viewers==2)|any(sets.viewers==1))*he.vz+...
        any(sets.viewers==3)*he.vy*imsize(2);
    %if ~any(sets.viewers==2)
    %    v_w=imsize(2)*he.vy;
    %else
   %     v_w=(any(sets.viewers==3)|any(sets.viewers==1))*imsize(2)*he.vy+imsize(3)*he.vz;
   % end

    %if use voxel size
    if sets.usevoxelsize
        %warning('Voxel size not supported for neurological');
        po=h_off*3+v_avail*h_w/v_w;
        %dont chnage aspect ratio of figure too much at once
        if po/pos(3)>3 
            pos(4)=pos(4)*0.75;
            set(h,'Position',pos);
            setAxesPositions(h);
            return
        end
        pos(3)=po;
        set(h,'Position',pos);
    end

    if any(sets.viewers==1)&any(sets.viewers==2)
        h_avail=pos(3)-h_off*3;
    else
        h_avail=pos(3)-h_off*2;
    end
else
    %standard convention
    
    if any(sets.viewers==2)&(any(sets.viewers==1)|any(sets.viewers==3))
        v_avail=pos(4)-ver_rem-ver_of-v_off;
    else
        v_avail=pos(4)-ver_rem-ver_of;
    end

    if ~any(sets.viewers==3)
        if any(sets.viewers==2)
            h_w=max(imsize(3)*he.vz,imsize(1)*he.vx);
        else
            h_w=imsize(3)*he.vz;
        end
    else
        h_w=imsize(1)*he.vx+any(sets.viewers==1)*imsize(3)*he.vz;
    end
    if ~any(sets.viewers==2)
        v_w=imsize(2)*he.vy;
    else
        v_w=(any(sets.viewers==3)|any(sets.viewers==1))*imsize(2)*he.vy+imsize(3)*he.vz;
    end

    %if use voxel size
    if sets.usevoxelsize
        po=h_off*3+v_avail*h_w/v_w;
        %dont chnage aspect ratio of figure too much at once
        if po/pos(3)>3 
            pos(4)=pos(4)*0.75;
            set(h,'Position',pos);
            setAxesPositions(h);
            return
        end
        pos(3)=po;
        set(h,'Position',pos);
    end

    if any(sets.viewers==3)&any(sets.viewers==1)
        h_avail=pos(3)-h_off*3;
    else
        h_avail=pos(3)-h_off*2;
    end
end



%maximum slider and textbox
set(val_sl_h(2),'Units','pixels','Position',[ h_off, v_off,pos(3)-3*h_off-h_in_te,v_sl]);
set(val_ed_h(2),'Units','pixels','Position',[pos(3)-h_in_te-h_off, v_off, h_in_te, v_sl]);

%minimum_slider and textbox
set(val_sl_h(1),'Units','pixels','Position',[ h_off, v_sl+2*v_off,pos(3)-3*h_off-h_in_te,v_sl]);
set(val_ed_h(1),'Units','pixels','Position',[pos(3)-h_in_te-h_off,v_sl+2* v_off, h_in_te, v_sl]);


%set frame position
set(frame_h,'Units','pixels','Position',[h_off,pos(4)-v_off-v_fr,pos(3)-2*h_off,v_fr]);


%set plane boxes
set(plane_te_h(1),'Units','pixels','Position',[h_off*2,pos(4)-v_off-v_int-v_sl,15,v_sl]);
set(plane_ed_h(1),'Units','pixels','Position',[h_off*4,pos(4)-v_off-v_int-v_sl,h_pl,v_sl]);

set(plane_te_h(2),'Units','pixels','Position',[h_off*5+h_pl,pos(4)-v_off-v_int-v_sl,15,v_sl]);
set(plane_ed_h(2),'Units','pixels','Position',[h_off*7+h_pl,pos(4)-v_off-v_int-v_sl,h_pl,v_sl]);

set(plane_te_h(3),'Units','pixels','Position',[h_off*8+h_pl*2,pos(4)-v_off-v_int-v_sl,15,v_sl]);
set(plane_ed_h(3),'Units','pixels','Position',[h_off*10+h_pl*2,pos(4)-v_off-v_int-v_sl,h_pl,v_sl]);

%set position info text
set(pos_te_h,'Units','pixels','Position',[pos(3)-2*h_off-h_po,pos(4)-v_off-v_int-v_sl,h_po,v_sl]);
%set(lab_te_h,'Units','pixels','Position',[pos(3)-3*h_off-2*h_po,pos(4)-v_off-v_int-v_sl,h_po,v_sl]);
set(lab_te_h,'Units','pixels','Position',[h_off*11+h_pl*2,pos(4)-v_off-v_int-v_sl,h_po,v_sl]);

%set field text just under position text
set(field_te_h,'Units','pixels','Position',[pos(3)-2*h_off-h_po,pos(4)-v_off-v_int*1.6-v_sl,h_po,v_sl/1.5]);


%if no viewers, nothing to do
if isempty(sets.viewers)
    return
end


if sets.neuro==1
    %neuro convention
    if any(sets.viewers==3)
        w=he.vx*h_avail*imsize(1)/h_w;
        u=he.vy*v_avail*imsize(2)/v_w;
        po=[h_off,ver_of,w,u];
        set(ax_h(3),'Units','pixels','Position',po);
    end
    if any(sets.viewers==1)
      %  w=he.vz*h_avail*imsize(3)/h_w;
      %  u=he.vy*v_avail*imsize(2)/v_w;
        w=he.vy*h_avail*imsize(2)/h_w;
        u=he.vz*v_avail*imsize(3)/v_w;
        
        %po=[h_off,ver_of,w,u];
        %po=[h_off,pos(4)-ver_rem-u,w,u];
        po=[pos(3)-h_off-w,pos(4)-ver_rem-u,w,u];
        set(ax_h(1),'Units','pixels','Position',po);
    end
    if any(sets.viewers==2)
        w=he.vx*h_avail*imsize(1)/h_w;
        u=he.vz*v_avail*imsize(3)/v_w;
        po=[h_off,pos(4)-ver_rem-u,w,u];
        set(ax_h(2),'Units','pixels','Position',po);
    end
else
    if any(sets.viewers==3)
        w=he.vx*h_avail*imsize(1)/h_w;
        u=he.vy*v_avail*imsize(2)/v_w;
        po=[pos(3)-h_off-w,ver_of,w,u];
        set(ax_h(3),'Units','pixels','Position',po);
    end
    if any(sets.viewers==1)
        w=he.vz*h_avail*imsize(3)/h_w;
        u=he.vy*v_avail*imsize(2)/v_w;
        po=[h_off,ver_of,w,u];
        
        set(ax_h(1),'Units','pixels','Position',po);
    end
    if any(sets.viewers==2)
        w=he.vx*h_avail*imsize(1)/h_w;
        u=he.vz*v_avail*imsize(3)/v_w;
        po=[pos(3)-h_off-w,pos(4)-ver_rem-u,w,u];
        set(ax_h(2),'Units','pixels','Position',po);
    end
end




%redraw all not realy needed oafter repositioning
% but some functions rely on it happening here
setImageInAxes(h);
redrawAll(h);
return


%%%%%%%%%%%%%%%% old version %%%%%%%%%%
% sets axes to position, taking image size and eventually
% viewrs into account
% correct for non 
ratio=650/700;
sets=getappdata(h,'ViewerSettings');
imsize=getappdata(h,'imsize');
ax_h=getappdata(h,'Axes');
cross_li_h=getappdata(h,'CrossLines');
%calculate relative sizes
rel_size=0.85;
rsize(1)=rel_size*(imsize(1)/(imsize(1)+imsize(3)));
rsize(2)=rel_size*(imsize(2)/(imsize(1)+imsize(3)));
rsize(3)=rel_size*(imsize(3)/(imsize(1)+imsize(3)));
setappdata(h,'rsize',rsize);

if any(sets.viewers==1)
    set(ax_h(1),'Position',[0.05 0.1 rsize(3) ratio*rsize(2)],...
        'XLim',[0.5 imsize(3)+0.5],'YLim',[0.5 imsize(2)+0.5]);
    set(cross_li_h(1,2),'XData',get(ax_h(1),'XLim'));
    set(cross_li_h(1,1),'YData',get(ax_h(1),'YLim'));
end
if any(sets.viewers==2)
    set(ax_h(2),'Position',[0.07+rsize(3) 0.12+ratio*rsize(2) rsize(1) ratio*rsize(3)],...
        'XLim',[0.5 imsize(1)+0.5],'YLim',[0.5 imsize(3)+0.5]);
    set(cross_li_h(2,2),'XData',get(ax_h(2),'XLim'));
    set(cross_li_h(2,1),'YData',get(ax_h(2),'YLim'));
end
if any(sets.viewers==3)
    set(ax_h(3),'Position',[0.07+rsize(3) 0.1 rsize(1) ratio*rsize(2)],...
        'XLim',[0.5 imsize(1)+0.5],'YLim',[0.5 imsize(2)+0.5]);
    set(cross_li_h(3,2),'XData',get(ax_h(3),'XLim'));
    set(cross_li_h(3,1),'YData',get(ax_h(3),'YLim'));
end
redrawAll(h);
return
   

function ima=loadImage(h,fname)
% tries to load image, inr only for the moment
% returns image of size 1,1,1 if fails
try 
    % you should supply a function that thakes the image
    % name as an input, and returns the image
    % as the first output argument, and eventually an header structure
    % containing the voxel sizes in the fiels vx, vy and vz.
    % Example :   [ima,header]=loadinr(fname);
    [ima,header]=loadinr(fname);
    if ~isempty(header)
        sets=getappdata(h,'ViewerSettings');
        sets.header=1;
        %check if voxel size is specified
        if ~isfield(header,'vx')
            header.vx=1;
            header.vy=1;
            header.vz=1;
        end
        setappdata(h,'ViewerSettings',sets);
        setappdata(h,'Header',header);
    end
catch
    warning(sprintf('Image %s could not be loaded',fname));
    ima=0;
end

function doImageButton(ha,evd,h,im_h,ax_h,viewer)
%function doImageButton(im_h,evd,h,ax_h,viewer)
%handles clicks on image planes
% ha is unknown handle, because function also reacts to line clicks etc..
sets=getappdata(h,'ViewerSettings');
%dispatch click types
switch get(h,'SelectionType')
    %double click
case 'open'
    if sets.own_zoom 
        % reset zoom to one
        sets.own_zoom_factor=1;
        setappdata(h,'ViewerSettings',sets);
        setImageInAxes(h);
        if sets.own_zoom_linked
            applyLinkedZoom(h,1);
        end
    else
        doImageDoubleClick(im_h,evd,h,ax_h,viewer);
    end
    %middle button, select image planes
case 'extend'
    %do not move planes if images are in zoom mode
    if ~sets.zoom&~sets.own_zoom
        set(h,'WindowButtonUpFcn',{@doUpSelectPlane});
        set(h,'WindowButtonMotionFcn',{@doMotionSelectPlane,ax_h,im_h,viewer});
        doSelectPlane(h,evd,ax_h,im_h,viewer);
    end
    %for own zoom mode move plane nut other motion function
    if sets.own_zoom  
        cur=get(h,'CurrentPoint');
        set(h,'WindowButtonUpFcn',{@doUpZoomPlane,cur});      
        set(h,'WindowButtonMotionFcn',{@doMotionZoomPlane,cur});
        doSelectPlane(h,evd,ax_h,im_h,viewer);
    end    
    return
    % left button, inspect image values and drawing
case 'normal'
    switch sets.draw
    case 1
        %do default drawing
        doRectangleDraw(h,evd,ax_h,im_h,viewer);
    otherwise
        %do inspection
        set(h,'WindowButtonUpFcn',{@doUpInspect});
        set(h,'WindowButtonMotionFcn',{@doMotionInspect,ax_h,im_h,viewer});
        doInspect(h,evd,ax_h,im_h,viewer);
    end
end
return

function doRectangleDraw(h,evd,ax_h,im_h,viewer)
%function draws rectangle in drawcolor
pos_start=get(ax_h,'CurrentPoint');
rect=rbbox;
pos_end=get(ax_h,'CurrentPoint');
%get settings and change image
sets=getappdata(h,'ViewerSettings');
posi=sets.plane;
image=getappdata(h,'Image');
imsize=getappdata(h,'imsize');
% translate coordinates in the right way
switch viewer
case 1
    if sets.neuro
        bs=round(max(1,min(imsize(3),pos_start(2,2))));
        be=round(max(1,min(imsize(3),pos_end(2,2))));
        as=round(max(1,min(imsize(2),pos_start(2,1))));
        ae=round(max(1,min(imsize(2),pos_end(2,1))));
    else
        as=round(max(1,min(imsize(2),pos_start(2,2))));
        ae=round(max(1,min(imsize(2),pos_end(2,2))));
        bs=round(max(1,min(imsize(3),pos_start(2,1))));
        be=round(max(1,min(imsize(3),pos_end(2,1))));
    end
    
    if sets.block
        image(1:end,min(as,ae):max(as,ae),min(bs,be):max(bs,be))=sets.drawcolor;
    else
        image(posi(1),min(as,ae):max(as,ae),min(bs,be):max(bs,be))=sets.drawcolor;
    end
case 2
    as=round(max(1,min(imsize(1),pos_start(2,1))));
    ae=round(max(1,min(imsize(1),pos_end(2,1))));
    bs=round(max(1,min(imsize(3),pos_start(2,2))));
    be=round(max(1,min(imsize(3),pos_end(2,2))));
    if sets.block
        image(min(as,ae):max(as,ae),1:end,min(bs,be):max(bs,be))=sets.drawcolor;
    else
        image(min(as,ae):max(as,ae),posi(2),min(bs,be):max(bs,be))=sets.drawcolor;
    end
case 3
    as=round(max(1,min(imsize(1),pos_start(2,1))));
    ae=round(max(1,min(imsize(1),pos_end(2,1))));
    bs=round(max(1,min(imsize(2),pos_start(2,2))));
    be=round(max(1,min(imsize(2),pos_end(2,2))));
    if sets.block
        image(min(as,ae):max(as,ae),min(bs,be):max(bs,be),1:end)=sets.drawcolor; 
    else
        image(min(as,ae):max(as,ae),min(bs,be):max(bs,be),posi(3))=sets.drawcolor; 
    end
end
% set image
setappdata(h,'Image',image);

%finally redraw image
redrawAll(h);


function doInspect(h,evd,ax_h,im_h,viewer)
% set planes to current mouse position
pos=round(get(ax_h,'CurrentPoint'));
imsize=getappdata(h,'imsize');
sets=getappdata(h,'ViewerSettings');
posi=sets.plane;
% translate coordinates in the right way
switch viewer
case 1
    if ~sets.neuro
        posi(2)=max(1,min(imsize(2),pos(2,2)));
        posi(3)=max(1,min(imsize(3),pos(2,1)));
    else
        posi(3)=max(1,min(imsize(3),pos(2,2)));
        posi(2)=max(1,min(imsize(2),pos(2,1)));
    end
case 2
    posi(1)=max(1,min(imsize(1),pos(2,1)));
    posi(3)=max(1,min(imsize(3),pos(2,2)));
case 3
    posi(1)=max(1,min(imsize(1),pos(2,1)));
    posi(2)=max(1,min(imsize(2),pos(2,2)));
end
%setappdata(h,'ViewerSettings',sets);
%fprintf('%i %i %i\n',sets.plane(1),sets.plane(2),sets.plane(3));
ima=getappdata(h,'Image');

%take care if no image, like in mixer case
if ~sets.ismixer    
    %handle freeform drawing
    if sets.draw==2
       ima(posi(1),posi(2),posi(3))=sets.drawcolor;
       setappdata(h,'Image',ima);
       %redraw is necessary if drawing freeform
       %siwtch off lines movement to prevent flicker
       ocross =sets.show_cross;
       sets.show_cross =0;
       setappdata(h,'ViewerSettings',sets);
       redrawAll(h);
       sets.show_cross=ocross;
       setappdata(h,'ViewerSettings',sets);
       %redrawAll(h);
       val =sets.drawcolor;
   else
       val = ima(posi(1),posi(2),posi(3));
   end
else
    val = NaN;
end
redrawPosition(h,posi,val);
if sets.show_cross
    redrawScaleLines(h,posi);
end

% link part
if ~isempty(getappdata(h,'LinkFigs'))
    % make sure all links are OK
    checkLinks(h);
    linkfigs=getappdata(h,'LinkFigs');
    %process all linked images
    for i=linkfigs
        l_sets=getappdata(i,'ViewerSettings');
        try
            ima=getappdata(i,'Image');
            redrawPosition(i,posi,ima(posi(1),posi(2),posi(3)));
            % if position was not valid, at least the following code will not be executed
            if l_sets.show_cross
                redrawScaleLines(i,posi);
            end
        catch
            %thing got messy...
            %warning(sprintf('Invalid linking',get(i,'Name')));
            % show invalid location
            redrawPosition(i,[NaN NaN NaN],NaN);
        end
    end
end

%do external inspect if it exists
if ~isempty(sets.posfunc)
    feval(sets.posfunc,posi,h,'normal');
end

return

function doMotionInspect(h,evd,ax_h,im_h,viewer)
% track inspection
doInspect(h,evd,ax_h,im_h,viewer);
return

function doUpInspect(h,evd)
% end of inspection
set(h,'WindowButtonMotionFcn','');
set(h,'WindowButtonUpFcn','');
return

function doSelectPlane(h,evd,ax_h,im_h,viewer)
% set planes to current mouse position
pos=round(get(ax_h,'CurrentPoint'));
imsize=getappdata(h,'imsize');
sets=getappdata(h,'ViewerSettings');
% translate coordinates in the right way
switch viewer
case 1
    if sets.neuro
        sets.plane(3)=max(1,min(imsize(3),pos(2,2)));
        sets.plane(2)=max(1,min(imsize(2),pos(2,1)));
    else
        sets.plane(2)=max(1,min(imsize(2),pos(2,2)));
        sets.plane(3)=max(1,min(imsize(3),pos(2,1)));
    end
    
case 2
    sets.plane(1)=max(1,min(imsize(1),pos(2,1)));
    sets.plane(3)=max(1,min(imsize(3),pos(2,2)));
case 3
    sets.plane(1)=max(1,min(imsize(1),pos(2,1)));
    sets.plane(2)=max(1,min(imsize(2),pos(2,2)));
end
setappdata(h,'ViewerSettings',sets);
%fprintf('%i %i %i\n',sets.plane(1),sets.plane(2),sets.plane(3));
redrawPlanes(h,setdiff(sets.viewers,viewer));

%do external inspect if it exists
if ~isempty(sets.posfunc)
    feval(sets.posfunc,sets.plane,h,'extend');
end


function doUpSelectPlane(h,evd)
% end of plane selection
set(h,'WindowButtonMotionFcn','');
set(h,'WindowButtonUpFcn','');
return

function doMotionSelectPlane(h,evd,ax_h,im_h,viewer)
% track plane selection
doSelectPlane(h,evd,ax_h,im_h,viewer);
return

function fac=getZoomFactor(base,cur)
%calculates zoom factor
fac=sign(-base(2)+cur(2))*sum((base(2)-cur(2)).^2)/1000;

function doUpZoomPlane(h,evd,base)
% end of plane selection
set(h,'WindowButtonMotionFcn','');
set(h,'WindowButtonUpFcn','');
sets=getappdata(h,'ViewerSettings');
sets.own_zoom_factor = max(getZoomFactor(base,get(h,'CurrentPoint'))+sets.own_zoom_factor,0.05);
setappdata(h,'ViewerSettings',sets);
return

function doMotionZoomPlane(h,evd,base)
% track zoom plane selection
sets=getappdata(h,'ViewerSettings');
imsize=getappdata(h,'imsize');
%calculate zoom factor
factor = max(getZoomFactor(base,get(h,'CurrentPoint'))+sets.own_zoom_factor,0.05);
ax_h=getappdata(h,'Axes');
%doSelectPlane(h,evd,ax_h,im_h,viewer);
if any(sets.viewers==1)
    if sets.neuro
        set(ax_h(1),...
            'YLim',([0.5 imsize(3)+0.5]-sets.plane(3))/factor+sets.plane(3),...
            'XLim',([0.5 imsize(2)+0.5]-sets.plane(2))/factor+sets.plane(2));
    else
        set(ax_h(1),...
            'XLim',([0.5 imsize(3)+0.5]-sets.plane(3))/factor+sets.plane(3),...
            'YLim',([0.5 imsize(2)+0.5]-sets.plane(2))/factor+sets.plane(2));
    end
    
end
if any(sets.viewers==2)
    set(ax_h(2),...
        'XLim',([0.5 imsize(1)+0.5]-sets.plane(1))/factor+sets.plane(1),...
        'YLim',([0.5 imsize(3)+0.5]-sets.plane(3))/factor+sets.plane(3));
end
if any(sets.viewers==3)
    set(ax_h(3),...
        'XLim',([0.5 imsize(1)+0.5]-sets.plane(1))/factor+sets.plane(1),...
        'YLim',([0.5 imsize(2)+0.5]-sets.plane(2))/factor+sets.plane(2));
end
if sets.own_zoom_linked
    applyLinkedZoom(h,factor);
end
return
    
function applyLinkedZoom(h,factor)
%applies zoom of factor to all images
%and stores the zoom foctor for the image
if(~isempty(getappdata(h,'LinkFigs')))
    % make sure all links are OK
    checkLinks(h);
    linkfigs=getappdata(h,'LinkFigs');
    %process all linked images
    for i=linkfigs
        sets=getappdata(i,'ViewerSettings');
        imsize=getappdata(i,'imsize');
        ax_h=getappdata(i,'Axes');
        if any(sets.viewers==1)
            if sets.neuro
                set(ax_h(1),...
                    'YLim',([0.5 imsize(3)+0.5]-sets.plane(3))/factor+sets.plane(3),...
                    'XLim',([0.5 imsize(2)+0.5]-sets.plane(2))/factor+sets.plane(2));
            else
                set(ax_h(1),...
                    'XLim',([0.5 imsize(3)+0.5]-sets.plane(3))/factor+sets.plane(3),...
                    'YLim',([0.5 imsize(2)+0.5]-sets.plane(2))/factor+sets.plane(2));
                
            end
        end
        if any(sets.viewers==2)
            set(ax_h(2),...
                'XLim',([0.5 imsize(1)+0.5]-sets.plane(1))/factor+sets.plane(1),...
                'YLim',([0.5 imsize(3)+0.5]-sets.plane(3))/factor+sets.plane(3));
        end
        if any(sets.viewers==3)
            set(ax_h(3),...
                'XLim',([0.5 imsize(1)+0.5]-sets.plane(1))/factor+sets.plane(1),...
                'YLim',([0.5 imsize(2)+0.5]-sets.plane(2))/factor+sets.plane(2));
        end
        sets.own_zoom_factor=factor;
        setappdata(i,'ViewerSettings',sets);
    end
end
return


function doImageDoubleClick(im_h,evd,h,ax_h,viewer)
%fprintf('Doubleclick (%i)\n',viewer);
return

function doPlaneEdit(ed,evd,h,plane)
% get value of edit box
% put value in plane, and redraw all planes
sets=getappdata(h,'ViewerSettings');
imsize=getappdata(h,'imsize');
% accept only valid and integer values
sets.plane(plane)=max(1,min(imsize(plane),...
    round(str2num(get(ed,'String')))));
setappdata(h,'ViewerSettings',sets);
redrawAll(h);

function doFieldMenu(a,dev,h)
sets=getappdata(h,'ViewerSettings');
sets.fieldcolor=uisetcolor(sets.fieldcolor,'Choose field color:');
setappdata(h,'ViewerSettings',sets);
redrawAll(h);

function doFieldScaleMenu(a,dev,h)
sets=getappdata(h,'ViewerSettings');
sc=inputdlg('Enter field scale:','Field scale',1,{num2str(sets.fieldscale)});
%check for cancel
if ~isempty(sc)
    sc=str2num(sc{1});    
    sets.fieldscale=sc;
    setappdata(h,'ViewerSettings',sets);
    redrawAll(h);
end

function doUseRGBMenu(me_h,dev,h)
sets=getappdata(h,'ViewerSettings');
sets.RGB=1-sets.RGB;
setappdata(h,'ViewerSettings',sets);
if sets.RGB
    set(me_h,'Checked','on');
else
    set(me_h,'Checked','off');
end



function doZoom(a,dev,h)
% switch on and off zoom both in menus
% and by using standard zoom fyunction
%does zoom views independently
sets=getappdata(h,'ViewerSettings');
zoom_me_h=getappdata(h,'ZoomMenu');
sets.zoom=1-sets.zoom;
setappdata(h,'ViewerSettings',sets);
if sets.zoom
    set(zoom_me_h,'Checked','on');
    zoom(h,'on');
    %switch of other zoom
    if sets.own_zoom
        doOwnZoom([],[],h)
    end
else
    set(zoom_me_h,'Checked','off');
    zoom(h,'off');
end



function doOwnZoom(a,dev,h)
% switch on and off zoom both in menus
% and by using standard zoom fyunction
%does zoom views independently
sets=getappdata(h,'ViewerSettings');
own_zoom_me_h=getappdata(h,'OwnZoomMenu');
sets.own_zoom=1-sets.own_zoom;
setappdata(h,'ViewerSettings',sets);
if sets.own_zoom
    set(own_zoom_me_h,'Checked','on');
    %zoom(h,'on');
    if sets.zoom
        doZoom([],[],h)
    end
else
    set(own_zoom_me_h,'Checked','off');
    %zoom(h,'off');
end


function doOwnZoomLinked(a,dev,h)
% switch on and off zoom both in menus
% and by using standard zoom fyunction
%does zoom views independently
sets=getappdata(h,'ViewerSettings');
own_zoom_linked_me_h=getappdata(h,'OwnZoomLinkedMenu');
sets.own_zoom_linked=1-sets.own_zoom_linked;
if sets.own_zoom_linked
    set(own_zoom_linked_me_h,'Checked','on');
    %zoom(h,'on');
else
    set(own_zoom_linked_me_h,'Checked','off');
    %zoom(h,'off');
end
setappdata(h,'ViewerSettings',sets);


function doDrawRectangleMenu(a,dev,h)
%switches on and off drawing mode
sets=getappdata(h,'ViewerSettings');
draw_me_h=getappdata(h,'DrawRectangleMenu');
if sets.draw>0
    sets.draw=0;
else
    sets.draw=1;
end
if sets.draw
    set(draw_me_h,'Checked','on');
    set(getappdata(h,'DrawFreeformMenu'),'Checked','off');
else
    set(draw_me_h,'Checked','off');
end
setappdata(h,'ViewerSettings',sets);


function doDrawFreeformMenu(a,dev,h)
%switches on and off drawing mode
sets=getappdata(h,'ViewerSettings');
draw_me_h=getappdata(h,'DrawFreeformMenu');
if sets.draw==2
    sets.draw=0;
else
    sets.draw=2;
end
if sets.draw==2
    set(draw_me_h,'Checked','on');
    set(getappdata(h,'DrawRectangleMenu'),'Checked','off');
else
    set(draw_me_h,'Checked','off');
end
setappdata(h,'ViewerSettings',sets);

function doSetValue(a,dev,h,name,title,redraw)
%general function to set a value with a window
% name of value
% title of window
% if redraw is needed
%creates simple function to set draw value
valed=[name 'Editor'];
if isappdata(h,valed);
    d_h = getappdata(h,valed);
else 
    d_h=[];
end
if isempty(d_h)|~ishandle(d_h)
sets=getappdata(h,'ViewerSettings');
d_h=figure('Name',[get(h,'Name') ': ' title],'Resize','off',...
    'Units','pixels','Position',[ 50 50 395 40],'Menubar','none',...
    'NumberTitle','off','HandleVisibility','off');
val_h=uicontrol('Parent',d_h,'Style','Slider','Units','Pixels','Position',[10  10 290 20] );
val_ed_h=uicontrol('Parent',d_h,'Style','edit','Units','Pixels','String','','HorizontalAlignment','right',...
    'Position',[310,10,75,20],'Callback',{@doValueEdit,h,d_h,val_h,name,redraw});
set(val_h,'Callback',{@doValueSlider,h,d_h,val_ed_h,name,redraw});
ax_h=getappdata(h,'Axes');
clim=get(ax_h(3),'Clim');
%make sure current color will fit limits
clim(1)=min(clim(1),getfield(sets,name));
clim(2)=max(clim(2),getfield(sets,name));
set(val_ed_h,'String',num2str(getfield(sets,name)));
set(val_h,'Value',getfield(sets,name),'Min',clim(1),'Max',clim(2));
setappdata(h,valed,d_h);
else
    figure(d_h);
end

function doValueSlider(a,dev,h,d_h,val_ed_h,name,redraw)
%function update value slider
val=get(a,'Value');
set(val_ed_h,'String',num2str(val));
if ishandle(h)
    sets=getappdata(h,'ViewerSettings');
    sets=setfield(sets,name,val);
    setappdata(h,'ViewerSettings',sets);
    if redraw
        redrawAll(h);
    end
else
    delete(d_h);
end

function doValueEdit(a,dev,h,d_h,val_h,name,redraw)
%function updates edit field 
mi=get(val_h,'min');
ma=get(val_h,'max');
val=str2num(get(a,'String'));
% if infinite value, 
% does not fit on slider bar
if ~isinf(val)
    if mi>val
        set(val_h,'Min',val)
    end
    if ma<val
        set(val_h,'Max',val)
    end
    set(val_h,'Value',val);
end
if ishandle(h)
    sets=getappdata(h,'ViewerSettings');
    sets = setfield(sets,name,val);
    setappdata(h,'ViewerSettings',sets);
    if redraw
        redrawAll(h);
    end
else
    delete(d_h);
end



function doSetDrawValueMenu(a,dev,h)
%creates simple function to set draw value
d_h = getappdata(h,'DrawValueEditor');
if isempty(d_h)|~ishandle(d_h)
sets=getappdata(h,'ViewerSettings');
d_h=figure('Name',[get(h,'Name') ': Draw Value'],'Resize','off',...
    'Units','pixels','Position',[ 50 50 395 40],'Menubar','none',...
    'NumberTitle','off');
val_h=uicontrol('Parent',d_h,'Style','Slider','Units','Pixels','Position',[10  10 290 20] );
val_ed_h=uicontrol('Parent',d_h,'Style','edit','Units','Pixels','String','','HorizontalAlignment','right',...
    'Position',[310,10,75,20],'Callback',{@doDrawValueEdit,h,d_h,val_h});
set(val_h,'Callback',{@doDrawValueSlider,h,d_h,val_ed_h});
ax_h=getappdata(h,'Axes');
clim=get(ax_h(3),'Clim');
%make sure current color will fit limits
clim(1)=min(clim(1),sets.drawcolor);
clim(2)=max(clim(2),sets.drawcolor);
set(val_ed_h,'String',num2str(sets.drawcolor));
set(val_h,'Value',sets.drawcolor,'Min',clim(1),'Max',clim(2));
setappdata(h,'DrawValueEditor',d_h);
else
    figure(d_h);
end


function doDrawValueSlider(a,dev,h,d_h,val_ed_h)
%function update value slider
val=get(a,'Value');
set(val_ed_h,'String',num2str(val));
if ishandle(h)
    sets=getappdata(h,'ViewerSettings');
    sets.drawcolor=val;
    setappdata(h,'ViewerSettings',sets);
else
    delete(d_h);
end

function doDrawValueEdit(a,dev,h,d_h,val_h)
%function updates edit field 
mi=get(val_h,'min');
ma=get(val_h,'max');
val=str2num(get(a,'String'));
% if infinite value, 
% does not fit on slider bar
if ~isinf(val)
    if mi>val
        set(val_h,'Min',val)
    end
    if ma<val
        set(val_h,'Max',val)
    end
    set(val_h,'Value',val);
end
if ishandle(h)
    sets=getappdata(h,'ViewerSettings');
    sets.drawcolor=val;
    setappdata(h,'ViewerSettings',sets);
else
    delete(d_h);
end




function doBlockMenu(a,dev,h)
%switches on and off drawing mode
sets=getappdata(h,'ViewerSettings');
block_me_h=getappdata(h,'BlockMenu');
if sets.block>0
    sets.block=0;
else
    sets.block=1;
end
if sets.block
    set(block_me_h,'Checked','on');
else
    set(block_me_h,'Checked','off');
end
setappdata(h,'ViewerSettings',sets);



function doWorkspaceMenu(a,dev,h)
% export image to workspace
sets=getappdata(h,'ViewerSettings');
varname = inputdlg('Variable name: ','Export image to workspace variable',1,{sets.varname});
if ~isempty(varname)
    sets.varname=varname{1};
    assignin('base',sets.varname,getappdata(h,'Image'));
    setappdata(h,'ViewerSettings',sets);
end

function do3DMenu(a,dev,h)
% creates new figure and shows data
sets=getappdata(h,'ViewerSettings');
var = inputdlg('Iso surface value: ',[get(h,'Name') ': Create isosurface'],1,{num2str(sets.isovaluethresh)});
if ~isempty(var)
    sets.isovaluethresh=str2num(var{1});
    imsize=getappdata(h,'imsize');
    f=isosurface(getappdata(h,'Image'),sets.isovaluethresh);
    f.vertices=f.vertices(:,[2 1 3]);
    %reduce number of faces
    nr_fa = size(f.faces,1);
    if nr_fa>8000
        f=reducepatch(f,round(nr_fa/8));
        
    end
        
    %switch coordinate system
    % create new figure if necessary
    if (sets.addaxes==0)|~ishandle(sets.addaxes)
        h3=figure;    
        p=patch(f);
        daspect([1 1 1])
        view(3); 
        camlight
    else
        p=patch(f,'Parent',sets.addaxes);
    end
    %isonormals(getappdata(h,'Image'),p)
    set(p,'FaceColor','red','EdgeColor','none');
    setappdata(h,'ViewerSettings',sets);
end


function doResize(a,dev,h)
%reset positions when resizing
setAxesPositions(h);
return

function doPlanesMenuOld(a,dev,h,plane)
sets=getappdata(h,'ViewerSettings');
in=sets.viewers==plane;
ax_h=getappdata(h,'Axes');
if any(in)
    sets.viewers=sets.viewers(~in);
    set(a,'Checked','off');
    set(get(ax_h(plane),'Children'),'Visible','off');
else
    sets.viewers=[plane sets.viewers];
    set(get(ax_h(plane),'Children'),'Visible','on');
    set(a,'Checked','on');
    cross_li_h=getappdata(h,'CrossLines');
    if sets.show_cross
        
        set(cross_li_h(plane,:),'Visible','on');
    else
        set(cross_li_h(plane,:),'Visible','off');
    end
end
setappdata(h,'ViewerSettings',sets);
setAxesPositions(h);

function doPlanesMenu(a,dev,h,plane)
%set sets.viewers to right values
sets=getappdata(h,'ViewerSettings');
in=sets.viewers==plane;
if any(in)
    sets.viewers=sets.viewers(~in);
else
    sets.viewers=[plane sets.viewers];
end
setappdata(h,'ViewerSettings',sets);
doPlanesSwitch(h);

function doPlanesSwitch(h)
%function updates plen menus
% and views visibilities based on sets.viewer
sets=getappdata(h,'ViewerSettings');
ax_h=getappdata(h,'Axes');
im_h=getappdata(h,'Images');  
cross_li_h=getappdata(h,'CrossLines');
planes_me_h=getappdata(h,'PlaneMenus');
%loop over possible views
for i=1:3
    if ~any(i==sets.viewers)
        set(planes_me_h(i),'Checked','off');
        set(cross_li_h(i,:),'Visible','off');
        set(im_h(i),'Visible','off');
    else
        set(im_h(i),'Visible','on');
        set(planes_me_h(i),'Checked','on');
        if sets.show_cross
            set(cross_li_h(i,:),'Visible','on');
        else
            set(cross_li_h(i,:),'Visible','off');
        end
    end
end
%change positions
setAxesPositions(h);

function doVoxMenu(a,dev,h)
%switches on and off use of voxelsize
sets=getappdata(h,'ViewerSettings');
vox_me_h=getappdata(h,'VoxMenu');
if sets.usevoxelsize>0
    sets.usevoxelsize=0;
    set(vox_me_h,'Checked','off');
else
    sets.usevoxelsize=1;
    set(vox_me_h,'Checked','on');
end
setappdata(h,'ViewerSettings',sets);
setAxesPositions(h);


function doSetVoxMenu(a,dev,h)
%sets voxelsize of header with dialog
header=getappdata(h,'Header');
res=inputdlg({'X size :','Y size :','Z size :'},'Set Voxelsize',1,...
    {num2str(header.vx),num2str(header.vy),num2str(header.vz)});
if ~isempty(res)
    header.vx=abs(str2num(res{1}));
    header.vy=abs(str2num(res{2}));
    header.vz=abs(str2num(res{3}));
    setappdata(h,'Header',header);
    sets=getappdata(h,'ViewerSettings');
    %automatically set use voxel size
    if ~sets.usevoxelsize
        doVoxMenu([],[],h);
    end
    %update axes positions
    setAxesPositions(h);
end

    
function doKeyPress(a,dev,h)
%process key presses
cc=get(h,'CurrentCharacter');
a=get(h,'CurrentAxes');
%find number of axes
ax_h=getappdata(h,'Axes');
ax=find(ax_h==a);
d=0;
%process key
switch cc
case {'q','Q','4'}
    %left
    d=-1;
case {'w','W','6'}
    %right
    d=1;
otherwise
    %unknown key
    %return
end

%try arrows key, might not be supported on 
% all platforms
cc=get(h,'CurrentKey');
switch cc
case {'uparrow','leftarrow'}
    %left
    d=-1;
case {'downarrow','rightarrow'}
    %right
    d=1;
otherwise
    %unknown key
    %return
end


%if key was not recognised
if d==0
    return
end


sets=getappdata(h,'ViewerSettings');
imsize=getappdata(h,'imsize');
sets.plane(ax)=min(max(1,sets.plane(ax)+d),imsize(ax));
setappdata(h,'ViewerSettings',sets);
redrawPlanes(h,ax);
return

function h_out=doOpenMenu(a,dev,h)
%open selected file in new window
[filename, pathname] = uigetfile({'*.inr;*.inr.gz;*.img','Image files'}, 'Pick an image');
if filename~=0
    h_out=feval(mfilename,[pathname,filename]);
else
    h_out=[];
end
return

function doDuplicateMenu(a,dev,h)
%create new viewer with the same image
sets=getappdata(h,'ViewerSettings');
name= ['Copy of ' get(h,'name')];
if sets.field
    feval(mfilename,getappdata(h,'Image'),getappdata(h,'Field'),name);
else
    feval(mfilename,getappdata(h,'Image'),name);
end


    
function doPrintMenu(a,dev,h)
%just calls print dialog box
printdlg(h)

function doPrintSetupMenu(a,dev,h)
%just calls print dialog box
printdlg('-setup',h)

function doPrintPreviewMenu(a,dev,h)
%just calls print preview 
printpreview(h);

function doFlipMenu(a,dev,h,dim)
%flip image along dimension
im = getappdata(h,'Image');
im = flipdim(im,dim);
setappdata(h,'Image',im);
if strcmp(get(a,'Checked'),'on')
	set(a,'Checked','off');
else
	set(a,'Checked','on');
end
redrawAll(h);

function doMipMenu(a,dev,h)
%set on or off mip
sets=getappdata(h,'ViewerSettings');
%change setting
sets.mip=1-sets.mip;
if sets.mip
    set(a,'Checked','on')
else
    set(a,'Checked','off')
end
setappdata(h,'ViewerSettings',sets);
%update image
redrawAll(h);


function doNeuroMenu(a,dev,h)
%set on or off mip
sets=getappdata(h,'ViewerSettings');
%change setting
sets.neuro=1-sets.neuro;
if sets.neuro
    set(a,'Checked','on')
else
    set(a,'Checked','off')
end
setappdata(h,'ViewerSettings',sets);
%update image
setAxesPositions(h);
redrawAll(h);




function doGotoMenu(a,dev,h,ty)
%goto maximum  or minimum value in image
im=getappdata(h,'Image');
switch ty
case 1
    [t,ind]=min(im(:));
case 2
    [t,ind]=max(im(:));
case 3
	var = inputdlg('Image value: ',...
			[get(h,'Name') ': Go to value'],1,{num2str(0)});
	if ~isempty(var)
		ind=find(im == str2num(var{1}));
		if isempty(ind)
			return;
		else
			ind = ind(1);
		end
	else
		return;
	end
end
sets=getappdata(h,'ViewerSettings');
[x,y,z]=ind2sub(size(im),ind);
sets.plane=[x y z];
setappdata(h,'ViewerSettings',sets);
%update image
redrawAll(h);

function doEvalMenu(a,dev,h)
i1 = getappdata(h,'Image');
var = inputdlg('function f(i1): ',...
		[get(h,'Name') ': Eval function'],1,{'i1'});
if isempty(var)
	return;
end
try,
	i1 = eval(var{1});
catch,
	disp(['Unable to evaluate: '  var{1}]);
end
setappdata(h,'Image',i1);
redrawAll(h);

function do3DSclicerMenu(a,dev,h)
sets=getappdata(h,'ViewerSettings');
sli_h=getappdata(h,'Slicer');
%check if slicer already exists
% and do not create new one
if (sets.slicer==1)&ishandle(sli_h)
    %just pop up
    figure(sli_h);
    return
end

% create 3D slicer and sets slicer to trur
sets.slicer =1;
figcrea=0;
setappdata(h,'ViewerSettings',sets);
%does not work with painter renderer
% create new figure if necessary
if (sets.addaxes==0)|~ishandle(sets.addaxes)
    set(0,'DefaultFigureCreateFcn',...
        'cameratoolbar')
    sli_h = figure('Renderer','OpenGL','Color','w');

    set(0,'DefaultFigureCreateFcn',[]);
    ax_h=axes('Parent',sli_h);
    
    set(ax_h,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[],'Box','on');
    set(ax_h,'XTick',[],'YTick',[],'ZTick',[]);
    hold on;
    view(3)%set print defaults
    setPrintDefaults(h);
    figcrea=1;
else
    ax_h=sets.addaxes;
    sli_h=get(ax_h,'Parent');
end
%prvent killing old lines
setappdata(h,'FieldSlicerLines',[{[]} {[]} {[]}]);

%cameramenu
setappdata(h,'Slicer',sli_h);
%create three surfaces
for i=1:4
    su_hs(1,i)=surface('Parent',ax_h,'FaceColor','texturemap',...
        'EdgeColor','none','FaceLighting','none',...
        'ButtonDownFcn',{@do3DSlicerButtonDown,h,sli_h,ax_h,1});
    su_hs(2,i)=surface('Parent',ax_h,'FaceColor','texturemap',...
        'EdgeColor','none','FaceLighting','none',...
        'ButtonDownFcn',{@do3DSlicerButtonDown,h,sli_h,ax_h,2});
    su_hs(3,i)=surface('Parent',ax_h,'FaceColor','texturemap',...
        'EdgeColor','none','FaceLighting','none',...
        'ButtonDownFcn',{@do3DSlicerButtonDown,h,sli_h,ax_h,3});
end
setappdata(h,'SliSurf',su_hs);
setappdata(h,'SliAxes',ax_h);
setAxesPositions(h);
redrawAll(h);
if ~sets.RGB
    set(sli_h,'Colormap',get(h,'Colormap'));
    ax_hs=getappdata(h,'Axes');
    set(ax_h,'CLim',get(ax_hs(3),'CLim'));
end
if figcrea
    
    %do only if new fig, othewise do not interfere with old settings
    set(ax_h,'ZDir','reverse');
    set(ax_h,'CameraViewAngle',get(ax_h,'cameraViewAngle'));
end
return
%OLD no RGB code
%copy colormap
set(sli_h,'Colormap',get(h,'Colormap'));
setAxesPositions(h);
redrawAll(h);
ax_hs=getappdata(h,'Axes');
%set colorsettings
set(ax_h,'CLim',get(ax_hs(3),'CLim'),'ZDir','reverse');


function doAlphaTypeMenu(me_h,dev,h,ty)
sets=getappdata(h,'ViewerSettings');
set(get(get(me_h,'Parent'),'Children'),'Checked','off');
set(me_h,'Checked','on');
sets.alphamap=ty;
setappdata(h,'ViewerSettings',sets);
if sets.slicer
    su_hs = getappdata(h,'SliSurf');
    if ty>1
        set(su_hs,'FaceAlpha','TextureMap','AlphaDataMapping','scaled');
    else
        set(su_hs,'FaceAlpha',1.0);
    end
    redrawAll(h);
end


function do3DSlicerButtonDown(s_h,dev,h,sli_h,ax_h,sli)
%function reacts when clicked on surface in slider
%start to check if figure still exists
%fprintf('Button down\n')

if ishandle(h)
    switch get(sli_h,'SelectionType')
        %double click
    case 'open'
        %middle button, 
    case 'extend'
        %left button
    case 'normal'
        %fprintf('Left Button down\n')
        pos=round(get(ax_h,'CurrentPoint'));
        set(sli_h,'WindowButtonUpFcn',{@doUp3DSclicer});
        sets=getappdata(h,'ViewerSettings');
        set(sli_h,'WindowButtonMotionFcn',{@doMotion3DSlicer,h,sli_h,ax_h,sli,pos,sets.plane});
    end
end
return


function doUp3DSclicer(h,dev)
set(h,'WindowButtonUpFcn','');
set(h,'WindowButtonMotionFcn','');

function doMotion3DSlicer(a,dev,h,sli_h,ax_h,sli,pos_ori,plane_ori)
%fprintf('Motion\n')
sets=getappdata(h,'ViewerSettings');
pos=round(get(ax_h,'CurrentPoint'));
imsize=getappdata(h,'imsize');
% translate coordinates in the right way

switch sli
case 1
    sets.plane(1)=max(1,min(imsize(1),pos(1,1)-pos_ori(1,1)+plane_ori(1)));
case 2
    sets.plane(2)=max(1,min(imsize(2),pos(1,2)-pos_ori(1,2)+plane_ori(2)));
case 3
    sets.plane(3)=max(1,min(imsize(3),pos(1,3)-pos_ori(1,3)+plane_ori(3)));
end
setappdata(h,'ViewerSettings',sets);
%fprintf('%i %i %i\n',sets.plane(1),sets.plane(2),sets.plane(3));
redrawPlanes(h,sli);



function doSetAddAxesMenu(a,evd,h)
%sets default add figure
sets=getappdata(h,'ViewerSettings');
set(0,'ShowHi','off');
ax_hs = findobj('type','axes');
%ax_hs = setdiff(ax_hs,getappdata(h,'Axes'));
str={'New figure'};
axr_hs=0;
for i=1:length(ax_hs)
    pa_h = get(ax_hs(i),'Parent');
    if ~strcmp(get(pa_h,'tag'),get(h,'tag'))    
        fig_name = get(pa_h,'Name');
        if isempty(fig_name)
            fig_name = ['Figure ' num2str(pa_h)];
        end
        str{end+1}=[fig_name ' ( ' num2str(ax_hs(i)) ')'];
        axr_hs(end+1)=ax_hs(i);
    end
end
ini = find(axr_hs==sets.addaxes);


[s,v] = listdlg('PromptString',{'Choose axes were new','slicers, and isosurfaces','will be shown.','','Default: new figure'},...
     'SelectionMode','single',...
     'ListString',str,...
     'InitialValue',ini,'Name',get(h,'Name'));
%do only someting if user clicked OK
if v
    sets.addaxes=axr_hs(s);
    setappdata(h,'ViewerSettings',sets);
end
 
 

function doRedrawMenu(a,dev,h);
%force redraw
redrawAll(h);

function doCloseAll(fig,evd,h)
close(findobj('tag',get(h,'tag')));

function doClose(fig,evd,h)
%close mixer if mixer window
sets=getappdata(h,'ViewerSettings');
if sets.ismixer delete(sets.mixer); end
if ishandle(h)
    delete(h);
end
return

function doDelete(a,dev,h)
%deletes everything

%delete draw avlue slider
d_h=getappdata(h,'DrawValueEditor');
if ishandle(d_h)
    delete(d_h);
end


function hh = my_quiver(varargin)
%QUIVER Quiver plot.
%   QUIVER(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVER automatically
%   scales the arrows to fit within the grid.
%
%   QUIVER(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVER(U,V,S) or QUIVER(X,Y,U,V,S) automatically scales the 
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER(...,'filled') fills any markers specified.
%
%   H = QUIVER(...) returns a vector of line handles.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiver(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVER3, PLOT.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2003/10/26 17:46:45 $

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

filled = 0;
ls = '-';
ms = '';
col = '';


%modified so that last argument is axes to plot in
nin = nargin-1;
% Parse the string inputs
while isstr(varargin{nin}),
  vv = varargin{nin};
  if ~isempty(vv) & strcmp(lower(vv(1)),'f')
    filled = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(vv);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',vv));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; plotarrows = 0; end
    if isequal(m,'.'), ms = ''; end % Don't plot '.'
    nin = nin-1;
  end
end

error(nargchk(2,5,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
  [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if nin==3 | nin==5, % quiver(u,v,s) or quiver(x,y,u,v,s)
  autoscale = varargin{nin};
end

% Scalar expand u,v
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n;
  dely = diff([min(y(:)) max(y(:))])/m;
  del = delx.^2 + dely.^2;
  if del>0
    len = sqrt((u.^2 + v.^2)/del);
    maxlen = max(len(:));
  else
    maxlen = 0;
  end
  
  if maxlen>0
    autoscale = autoscale*0.9 / maxlen;
  else
    autoscale = autoscale*0.9;
  end
  u = u*autoscale; v = v*autoscale;
end

%ax = newplot;
%next = lower(get(ax,'NextPlot'));
hold_state = ishold;

% Make velocity vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];

h1 = plot(uu(:),vv(:),[col ls],'Parent',varargin{nin+1});

if plotarrows,
  % Make arrow heads and plot them
  hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
        x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
  hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
        y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
  hold on
  h2 = plot(hu(:),hv(:),[col ls],'Parent',varargin{nin+1});
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y;
  hold on
  h3 = plot(hu(:),hv(:),[col ms]);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end

% do not understand so switch off
%if ~hold_state, hold off, view(2); set(ax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end

function hh = my_quiver3(varargin)
%QUIVER3 3-D quiver plot.
%   QUIVER3(X,Y,Z,U,V,W) plots velocity vectors as arrows with components
%   (u,v,w) at the points (x,y,z).  The matrices X,Y,Z,U,V,W must all be
%   the same size and contain the corresponding position and velocity
%   components.  QUIVER3 automatically scales the arrows to fit.
%
%   QUIVER3(Z,U,V,W) plots velocity vectors at the equally spaced
%   surface points specified by the matrix Z.
%
%   QUIVER3(Z,U,V,W,S) or QUIVER3(X,Y,Z,U,V,W,S) automatically
%   scales the arrows to fit and then stretches them by S.
%   Use S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER3(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER3(...,'filled') fills any markers specified.
%
%   H = QUIVER3(...) returns a vector of line handles.
%
%   Example:
%       [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%       z = x .* exp(-x.^2 - y.^2);
%       [u,v,w] = surfnorm(x,y,z);
%       quiver3(x,y,z,u,v,w); hold on, surf(x,y,z), hold off
%
%   See also QUIVER, PLOT, PLOT3, SCATTER.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2003/10/26 17:46:45 $

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1;

filled = 0;
ls = '-';
ms = '';
col = '';

%same mods as my_quiver
nin = nargin-1;
% Parse the string inputs
while isstr(varargin{nin}),
  vv = varargin{nin};
  if ~isempty(vv) & strcmp(lower(vv(1)),'f')
    filled = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(vv);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',vv));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; plotarrows = 0; end
    if isequal(m,'.'), ms = ''; end % Don't plot '.'
    nin = nin-1;
  end
end

error(nargchk(4,7,nin));

% Check numeric input arguments
if nin<6, % quiver3(z,u,v,w) or quiver3(z,u,v,w,s)
  [msg,x,y,z] = xyzchk(varargin{1});
  u = varargin{2};
  v = varargin{3};
  w = varargin{4};
else % quiver3(x,y,z,u,v,w) or quiver3(x,y,z,u,v,w,s)
  [msg,x,y,z] = xyzchk(varargin{1:3});
  u = varargin{4};
  v = varargin{5};
  w = varargin{6};
end
if ~isempty(msg), error(msg); end

% Scalar expand u,v,w.
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end
if prod(size(w))==1, w = w(ones(size(v))); end

% Check sizes
if ~isequal(size(x),size(y),size(z),size(u),size(v),size(w))
  error('The sizes of X,Y,Z,U,V, and W must all be the same.');
end

% Get autoscale value if present
if nin==5 | nin==7, % quiver3(z,u,v,w,s) or quiver3(x,y,z,u,v,w,s)
  autoscale = varargin{nin};
end

if length(autoscale)>1,
  error('S must be a scalar.');
end

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n; 
  dely = diff([min(y(:)) max(y(:))])/m;
  delz = diff([min(z(:)) max(y(:))])/max(m,n);
  del = sqrt(delx.^2 + dely.^2 + delz.^2);
  if del>0
    len = sqrt((u/del).^2 + (v/del).^2 + (w/del).^2);
    maxlen = max(len(:));
  else
    maxlen = 0;
  end
  
  if maxlen>0
    autoscale = autoscale*0.9 / maxlen;
  else
    autoscale = autoscale*0.9;
  end
  u = u*autoscale; v = v*autoscale; w = w*autoscale;
end

%ax = newplot;
%next = lower(get(ax,'NextPlot'));
%hold_state = ishold;

% Make velocity vectors
x = x(:).'; y = y(:).'; z = z(:).';
u = u(:).'; v = v(:).'; w = w(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];
ww = [z;z+w;repmat(NaN,size(u))];

h1 = plot3(uu(:),vv(:),ww(:),[col ls],'Parent',varargin{nin+1});

if plotarrows,
  beta = beta * sqrt(u.*u + v.*v + w.*w) ./ (sqrt(u.*u + v.*v) + eps);

  % Make arrow heads and plot them
  hu = [x+u-alpha*(u+beta.*(v+eps));x+u; ...
        x+u-alpha*(u-beta.*(v+eps));repmat(NaN,size(u))];
  hv = [y+v-alpha*(v-beta.*(u+eps));y+v; ...
        y+v-alpha*(v+beta.*(u+eps));repmat(NaN,size(v))];
  hw = [z+w-alpha*w;z+w;z+w-alpha*w;repmat(NaN,size(w))];

  hold on
  h2 = plot3(hu(:),hv(:),hw(:),[col ls],'Parent',varargin{nin+1});
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y; hw = z;
  hold on
  h3 = plot3(hu(:),hv(:),hw(:),[col ms]);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end

%if ~hold_state, hold off, view(3); grid on, set(ax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end





















%test function, is quicker then the original
% getappdata, but has nor error checking !!!
%if error in this function, disable it
% by changing it's name, to use original getappdata
%function gives error whereas getappdata return []
function r=getappdata(h,name)
r=subsref(get(h,'Applicationdata'),struct('type','.','subs',name));
%getfield(,name);
