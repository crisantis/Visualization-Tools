%PlotScaledVelocityProfiles.m
%% ========================================================================
%  VelocityRelaxationAnalysis.m
%  ------------------------------------------------------------------------
%  This script computes the velocity relaxation time and plots scaled
%  velocity profiles for various flow speeds, directions, and depths.
%
%  The code was made on : January 4th, 2019
%   For assistance, conact: atritinger@gmail.com
%
%  Description:
%  ------------------------------------------------------------------------
%  - Loads velocity (U,V) data from text files named using:
%       <dir>_<speed>_<depth>outU.txt / outV.txt
%  - Calculates relaxation times for each condition.
%  - Plots scaled velocity profiles versus depth.
%  - Optionally saves figures as PNGs.
%
%  Requirements:
%  ------------------------------------------------------------------------
%  - MATLAB R2018a or newer
%  - Data files formatted as described above.
%  - No dependency on cbrewer (uses built-in colormaps).
%
%  ========================================================================

clear; close all; clc;

%% ------------------------ USER PARAMETERS -------------------------------
dockit = @() set(gcf,'windowstyle','docked');   % Dock figures automatically
G = 9.81;                                       % Gravitational acceleration (m/s^2)
dt = 0.5;                                       % Time step [s]
small = 0.01;                                   % Convergence threshold

% Flow parameters
SPEED = [5,10,20,40];                           % Flow speeds [m/s]
DEPTH = [5,10,15,20,25,30];                     % Depths [m]
DIR   = [-90,-45,-22.5,0,22.5,45,90];           % Directions [degrees]

% Derived parameters
NUMSPEED = numel(SPEED);
NUMDEPTH = numel(DEPTH);
NUMDIR   = numel(DIR);

% Plot color schemes (no external cbrewer dependency)
BL = interp1(linspace(0,1,256), colormap('winter'), linspace(0,1,18));
RD = interp1(linspace(0,1,256), colormap('hot'), linspace(0,1,18));
rb = interp1(linspace(0,1,256), colormap('jet'), linspace(0,1,16));
rb = flipud(rb);

%% -------------------- COMPUTE RELAXATION TIMES --------------------------
fprintf('Computing relaxation times...\n');
REL = zeros(NUMSPEED, NUMDEPTH, NUMDIR); % Preallocate relaxation matrix

for i = 1:NUMSPEED
    valS = num2str(100 + SPEED(i));

    for l = 1:NUMDIR
        valdir = num2str(100 + l);

        for j = 1:NUMDEPTH
            NH = 41;             % Number of vertical nodes (user can generalize)
            TH = 1 / NH;         % Vertical step size
            valD = num2str(100 + DEPTH(j));

            % Construct filenames
            fileU = sprintf('%s_%s_%soutU.txt', valdir, valS, valD);
            fileV = sprintf('%s_%s_%soutV.txt', valdir, valS, valD);

            % Skip if files are missing
            if ~isfile(fileU) || ~isfile(fileV)
                warning('Missing files for Speed=%s, Dir=%s, Depth=%s', valS, valdir, valD);
                continue;
            end

            % Load data
            UU = load(fileU);
            VV = load(fileV);
            TIME = length(UU) / (NH + 1);

            % Last time-step profiles
            t = round(TIME - 1);
            lastU = UU(((NH+1)*(t-1)+2):((NH+1)*t), 1);
            lastV = VV(((NH+1)*(t-1)+2):((NH+1)*t), 1);

            % Initialize signal difference arrays
            sigU = zeros(TIME, 1);
            sigV = zeros(TIME, 1);

            % Compute signal decay
            for tt = 1:TIME
                curU = UU(((NH+1)*(tt-1)+2):((NH+1)*tt), 1);
                curV = VV(((NH+1)*(tt-1)+2):((NH+1)*tt), 1);

                sigU(tt) = sum((lastU - curU).^2) * TH;
                sigV(tt) = sum((lastV - curV).^2) * TH;
            end

            % Determine relaxation time (first time both signals below threshold)
            for tt = 1:TIME
                if abs(sigU(tt)) < small && abs(sigV(tt)) < small
                    REL(i,j,l) = tt;
                    break;
                end
            end
        end
    end
end

fprintf('Relaxation time computation complete.\n');

%% --------------------- PLOT SCALED VELOCITY PROFILES --------------------
fprintf('Plotting scaled velocity profiles...\n');
counter = 10;

for l = 2:NUMDIR-1
    valdir = num2str(100 + l);

    for j = 1:NUMDEPTH
        valD = num2str(100 + DEPTH(j));
        counter = counter + 1;

        figure(counter); hold on; grid on; grid minor;

        for i = 1:NUMSPEED
            valS = num2str(100 + SPEED(i));
            fileU = sprintf('%s_%s_%soutU.txt', valdir, valS, valD);

            if ~isfile(fileU)
                continue;
            end

            UU = load(fileU);
            t = round(length(UU)/(NH+1) - 1);
            SCALEU = UU(((NH+1)*(t-1)+2):((NH+1)*t), 1) * G / (NUMSPEED^2);

            % Plot U velocity profile
            plot(SCALEU, UU(2:(NH+1),2), ...
                'LineWidth', 2, 'Color', BL(i+10,:));
        end

        xlabel('Scaled Velocity Factor (-)');
        ylabel('Depth (m)');
        title(sprintf('Scaled Velocity @ Depth %.1fm, Direction %.1f°', ...
            DEPTH(j), DIR(l)));
        legend(arrayfun(@(s) sprintf('U @ %dm/s', s), SPEED, 'UniformOutput', false), ...
            'Location', 'Northwest', 'FontSize', 12);

        % Axis and export
        axis([-0.17, 0.23, -DEPTH(j), 0]);
        dockit();
        saveas(gcf, sprintf('ScaledFig_Dir%s_Depth%s.png', valdir, valD));
    end
end

fprintf('All figures generated and saved.\n');
