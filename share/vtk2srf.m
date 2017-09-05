function vtk2srf(varargin)
% Convert a VTK file generated by FSL-FIRST to a FreeSurfer
% surface file in ASCII format, with extension .srf.
% Note this is not supposed to read any other VTK file, but
% only those such as created by FSL-FIRST (i.e. POLYDATA).
%
% Usage:
% vtk2srf(filevtk,filesrf)
%
% filevtk : Input VTK file.
% filesrf : Output SRF file.
%
% _____________________________________
% Anderson M. Winkler
% FMRIB / Univ. of Oxford
% Oct/2015
% http://brainder.org

% Do OCTAVE stuff, with TRY to ensure MATLAB compatibility
try
    % Get the inputs
    varargin = argv();
    nargin = numel(varargin);

    % Disable memory dump on SIGTERM
    sigterm_dumps_octave_core(0);

    % Print usage if no inputs are given
    if isempty(varargin) || strcmp(varargin{1},'-q'),
        fprintf('Convert a VTK file generated by FSL-FIRST to a FreeSurfer\n');
        fprintf('surface file in ASCII format, with extension .srf.\n');
        fprintf('Note this is not supposed to read any other VTK file, but\n');
        fprintf('only those such as created by FSL-FIRST (i.e. POLYDATA).\n');
        fprintf('\n');
        fprintf('Usage:\n');
        fprintf('vtk2srf <filevtk> <filesrf>\n');
        fprintf('\n');
        fprintf('filevtk : Input VTK file.\n');
        fprintf('filesrf : Output SRF file.\n');
        fprintf('\n');
        fprintf('_____________________________________\n');
        fprintf('Anderson M. Winkler\n');
        fprintf('FMRIB / Univ. of Oxford\n');
        fprintf('Oct/2015\n');
        fprintf('http://brainder.org\n');
        return;
    end
end

% Take inputs:
filevtk = varargin{1};
filesrf = varargin{2};

fid = fopen(filevtk);
T = textscan(fid,'%s','CommentStyle','#','Delimiter','*'); % fake delimiter
fclose(fid);

for t = 1:10,
    if strcmp(T{1,1}{t,1}(1:5),'POINT'),
        nVtx = textscan(T{1,1}{t,1},'%s');
        nVtx = str2num(nVtx{1,1}{2,1});
        vtx = zeros(nVtx,3);
        for v = 1:nVtx,
           tmpvar = textscan(T{1,1}{v+t,1},'%n');
           vtx(v,:) = tmpvar{1}';
        end
        blah = t+nVtx+1;
        nFac = numel(T{1,1})-blah;
        fac = zeros(nFac,3);
        for f  = 1:nFac,
            tmpvar = textscan(T{1,1}{f+blah,1},'%n');
            fac(f,:) = tmpvar{1}(2:4)';
        end
    end
end

% Add an extra col of zeros to vtx and fac
vtx = [vtx zeros(size(vtx,1),1)];
fac = [fac zeros(size(fac,1),1)];

% Write to the disk
fid = fopen(filesrf,'w');
fprintf(fid,'#!ascii\n');                        % signature
fprintf(fid,'%g %g\n',size(vtx,1),size(fac,1));  % number of vertices and faces
fprintf(fid,'%f %f %f %g\n',vtx');               % vertex coords
fprintf(fid,'%g %g %g %g\n',fac');               % face indices
fclose(fid);