function icodown(varargin)
% Downsample a DPF file from a higher-order tessellated
% icosahedron to a lower order one. Note that the DPF
% file must have been derived from a suface file from either
% FreeSurfer or Brainder tools.
% 
% The downsampling method is pycnophylactic and, therefore,
% works only for quantities that require mass conservation,
% such as areal quantities.
% 
% Usage:
% icodown(dpfin,ntarget,dpfout)
% 
% - dpfin   : DPF file to be downsampled.
% - ntarget : Icosahedron order of the downsampled file.
% - dpfout  : Output DPF file, downsampled.
% 
% _____________________________________
% Anderson M. Winkler
% Yale University
% Apr/2012

% Do OCTAVE stuff, using TRY to ensure MATLAB compatibility
try
    % Get the inputs
    varargin = argv();
    
    % Disable memory dump on SIGTERM
    sigterm_dumps_octave_core(0);
    
    % Print usage if no inputs are given
    if isempty(varargin) || strcmp(varargin{1},'-q'),
        fprintf('Downsample a DPF file from a higher-order tessellated\n');
        fprintf('icosahedron to a lower order one. Note that the DPF\n');
        fprintf('file must have been derived from a suface file from either\n');
        fprintf('FreeSurfer or Brainder tools.\n');
        fprintf('\n');
        fprintf('The downsampling method is pycnophylactic and, therefore,\n');
        fprintf('works only for quantities that require mass conservation,\n');
        fprintf('such as areal quantities.\n');
        fprintf('\n');
        fprintf('Usage:\n');
        fprintf('icodown <dpfin> <ntarget> <dpfout>\n');
        fprintf('\n');
        fprintf('- dpfin   : DPF file to be downsampled.\n');
        fprintf('- ntarget : Icosahedron order of the downsampled file.\n');
        fprintf('- dpfout  : Output DPF file, downsampled.\n');
        fprintf('\n');
        fprintf('_____________________________________\n');
        fprintf('Anderson M. Winkler\n');
        fprintf('Yale University\n');
        fprintf('Apr/2012\n');
        return;
    end
end

% Accept arguments
dpxin   = varargin{1};
ntarget = varargin{2};
dpxout  = varargin{3};

% Read data from disk
[dpx,crd,idx] = dpxread(dpxin);
nX = numel(dpx);

% Detect what kind of data this is
if mod(nX,10),
    fprintf('Downsampling of vertexwise data not yet implemented\n');
    
    % % Compute icosahedron order
    % n = round(log((nX-2)/(V0-2))/log(4));
    %
    % % Sanity check
    %if nX ~= 4^n*(V0-2)+2,
    %    error('Data not from icosahedron\n');
    %elseif n >= ntarget,
    %    error('This script only downsamples data')
    %end
    
else
    
    % Compute icosahedron order
    n = round(log(nX/F0)/log(4));
    
    % Sanity check
    if nX ~= 4^n*F0,
        error('Data not from icosahedron\n');
    elseif n >= ntarget,
        error('This script only downsamples data')
    else
        fprintf('Downsampling facewise data\n');
    end
    
    % Downsample faces!
    for d = 1:(n-ntarget),
        dpx = reshape(dpx,[4 nX/4]);
        dpx = sum(dpx)';
    end
    
end

% Save to disk
nXdown = numel(dpx);
dpxwrite(dpxout,dpx,crd(1:nXdown,:),idx(1:nXdown,1));