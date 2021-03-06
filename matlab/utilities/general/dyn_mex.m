function dyn_mex(win_compiler,basename,force)

% Compile Dynare model dlls when model option use_dll is used
% if C file is fresher than mex file
%
% INPUTS
%  o win_compiler  str  compiler used under Windows (unused under Linux or OSX):
%                       'msvc' (MS Visual C)
%                        'cygwin'
%  o basename      str  filenames base
%  o force         bool recompile if 1
%
% OUTPUTS
%  none
%


% Copyright (C) 2015-2017 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

Dc = dir([basename '/mode/src/dynamic.c']);
Dmex = dir(['+' basename '/model/dynamic.' mexext]);

% compile only if date of C file is greater than date of mex file
% and force is not True
if ~isempty(Dmex)
    if (Dmex.datenum > Dc.datenum) && ~force
        disp('Mex files are newer than the source: not recompiled')
        return
    end
end

if ~exist('OCTAVE_VERSION')
    % Some mex commands are enclosed in an eval(), because otherwise it will make Octave fail
    if ispc
        if strcmp(win_compiler,'msvc')
            % MATLAB/Windows + Microsoft Visual C++
            % Add /TP flag as fix for #1227
            eval(['mex -O LINKFLAGS="$LINKFLAGS /export:Dynamic" COMPFLAGS="/TP" ' basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LINKFLAGS="$LINKFLAGS /export:Static" COMPFLAGS="/TP" ' basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        elseif strcmp(win_compiler,'mingw')
            eval(['mex -O LINKFLAGS="$LINKFLAGS /export:Dynamic" ' basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LINKFLAGS="$LINKFLAGS /export:Static"  ' basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        elseif strcmp(win_compiler,'cygwin') %legacy support for Cygwin with mexopts.bat
                                             % MATLAB/Windows + Cygwin g++
            eval(['mex -O PRELINK_CMDS1="echo EXPORTS > mex.def & echo ' ...
                  'mexFunction >> mex.def & echo Dynamic >> mex.def" ' ...
                  basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O PRELINK_CMDS1="echo EXPORTS > mex.def & echo ' ...
                  'mexFunction >> mex.def & echo Dynamic >> mex.def" ' ...
                  basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        else
            error(['When using the USE_DLL option, you must give either ' ...
                   '''cygwin'', ''mingw'' or ''msvc'' option to the ''dynare'' command'])
        end
    elseif isunix && ~ismac
        % MATLAB/Linux
        if matlab_ver_less_than('8.3')
            eval(['mex -O LDFLAGS=''-pthread -shared -Wl,--no-undefined'' ' ...
                  basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LDFLAGS=''-pthread -shared -Wl,--no-undefined'' ' ...
                  basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        elseif matlab_ver_less_than('9.1')
            eval(['mex -O LINKEXPORT='''' ' basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LINKEXPORT='''' ' basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        else
            eval(['mex -O LINKEXPORTVER='''' ' basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LINKEXPORTVER='''' ' basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        end
    elseif ismac
        % MATLAB/MacOS
        if matlab_ver_less_than('8.1')
            eval(['mex -O LDFLAGS=''-Wl,-twolevel_namespace -undefined ' ...
                  'error -arch $ARCHS -Wl,-syslibroot,$SDKROOT ' ...
                  '-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET -bundle'' ' ...
                  basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LDFLAGS=''-Wl,-twolevel_namespace -undefined ' ...
                  'error -arch $ARCHS -Wl,-syslibroot,$SDKROOT ' ...
                  '-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET -bundle'' ' ...
                  basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        elseif matlab_ver_less_than('8.3')
            eval(['mex -O LDFLAGS=''-Wl,-twolevel_namespace -undefined ' ...
                  'error -arch $ARCHS -Wl,-syslibroot,$MW_SDKROOT ' ...
                  '-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET -bundle'' ' ...
                  basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LDFLAGS=''-Wl,-twolevel_namespace -undefined ' ...
                  'error -arch $ARCHS -Wl,-syslibroot,$MW_SDKROOT ' ...
                  '-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET -bundle'' ' ...
                  basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        elseif matlab_ver_less_than('9.1')
            eval(['mex -O LINKEXPORT='''' ' basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LINKEXPORT='''' ' basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        else
            eval(['mex -O LINKEXPORT='''' LINKEXPORTVER='''' ' basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -output +' basename '/dynamic'])
            eval(['mex -O LINKEXPORT='''' LINKEXPORTVER='''' ' basename '/model/src/static.c ' basename '/model/src/static_mex.c -output +' basename '/static'])
        end
    end
else
    % Octave
    eval(['mex ' basename '/model/src/dynamic.c ' basename '/model/src/dynamic_mex.c -o +' basename '/dynamic'])
    eval(['mex ' basename '/model/src/static.c ' basename '/model/src/static_mex.c -o +' basename '/static'])
end
