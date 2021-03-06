function [data] = SMS_experiment_v1Beta(action,varargin)

action='run_exp';

try
	data = run_exp();
catch ME
    clean_exit()
    sca
    rethrow(ME) 
end
end

function [data] = run_exp()
sca;
close all;
clearvars;

data.dbstack = dbstack; %For debug ?
data.time.start = now; % Get the time when the task begin
rng('shuffle'); % seed the rand

data.debug = 0; %-- not in debug mode

% skiptraining = input('Skip Monetary ?');
% skipmonetary = input('Skip Monetary ?');
% skipsocial = input('Skip Monetary ?');


%% -- Prepare functions in memory
Screen('Screens');
KbName('UnifyKeyNames') %-- Unified key names across platforms

%% -- Task parameters
% load Matrix_test_oth_subj_data
data.parameters.task.ntrials = 3;
data.parameters.task.nruns = 1; 
data.parameters.task.score_ratio = 1;
data.parameters.task.rank_mat = [1,2,3,4,5]; % Matrice contenant les rangs
data.parameters.task.Table_payoff = [10,8,6,4,2];
data.text.jump_line = {'\n'};

%  Creates the score/rt matrix
a = 0.1:0.01:2;
b = 200:-1:10;
for xx = 1:191
    data.fction_score(1,xx) = a(1,xx);
    data.fction_score(2,xx) = b(1,xx);
end
% Creation bot (fake subjects)

    [data] = botscore(data);

%% -- Participant code

if data.debug ; data.participant.code = ''; return ; end
data.participant.code=input('Participant code (leave empty for testing): ', 's');
if isempty(data.participant.code) ; data.debug = 1 ;end
if data.debug ; data.datafile = []; else data.datafile = datestr(data.time.start,30); end

%% -- Write .log
Write_log(sprintf('Participant: %s',data.participant.code),data.datafile);
Write_log(sprintf('Data files: %s',data.datafile),data.datafile);

%% -- Psychtoolbox Graphics

ListenChar(2);              %-- "Ecouter le clavier ON" (0 = stop)
priorityLevel = 2;          %-- Ideally : priorityLevel = MaxPriority(data.frame.ptr,'KbCheck');
Priority(priorityLevel);
% HideCursor;                 %-- Hide mouse cursor
% Display PTB

PsychDefaultSetup(2); % Here we call some default settings for setting up Psychtoolbox
screens = Screen('Screens'); % Get the screen numbers
screenNumber = max(screens); % Draw to the external screen if avaliable

% Define black and white
sc.white = WhiteIndex(screenNumber);
sc.black = BlackIndex(screenNumber);

% Screen('Preference', 'SkipSyncTests', 2);
[window, sc.windowRect] = PsychImaging('OpenWindow', screenNumber, sc.black); % Open an on screen window
[sc.screenXpixels, sc.screenYpixels] = Screen('WindowSize', window); % Get the size of the on screen window

sc.ifi = Screen('GetFlipInterval', window); % Query the frame duration
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines

%% -- Beginning of run : time
    data.time.t0 = GetSecs;
    
%% -- Get ready
write_text(window,'.',sc.white);
                         
write_text(window,'Nous allons demarrer...',sc.white);
if ~data.debug ; WaitSecs(2); end

intro_text={'As soon as the fixation cross become a square, press Enter \n\n Press Any Key To Begin'};
        
write_text(window,intro_text{1},sc.white);

if ~data.debug ; save(data.datafile,'data') ; else save('tmp.mat','data') ; end

    
%% -- Training real effort (in construction)

    
%% -- Monetary trials (in construction)

% if ~skipmonetary
[data] = GetParams(data,sc,'monetary');
trialnb =0;
for i_run = 1 : data.parameters.task.nruns 
    for i_trial = 1 : data.parameters.task.ntrials
        trialnb = trialnb +1;
        dataM(trialnb,1) = i_run;
        dataM(trialnb,2) = trialnb;
        datax2 = SMS_run_trial_monetary_V1Beta(window,data,sc,data.parameters.task.monetary,i_trial);
        dataM(trialnb,3:12) = table2array(datax2);    
        if ~data.debug ; save(data.datafile,'data', 'dataM'); else save('tmp.mat','data', 'dataM'); end
    end
end
    %-- Inter trial Interval
    WaitSecs(2)
        
%% -- Social trials (in construction)




%% *********End*******
if ~data.debug ; save(data.datafile,'data', 'dataM') ; else save('tmp.mat','data', 'dataM') ; end
% Wait for a key press
KbStrokeWait;
% Clear the screen
clean_exit()
end


function []=clean_exit() 

Priority(0);
ListenChar(0);
ShowCursor
end

function [data] = botscore(data)
    for ii = 1:4
        for jj = 1:5
%             data.run.score_oth(jj) = [];
            test.Subj(ii).tr(jj).rt_square = 0.5 + (1.5-0.3).*rand(1,1); % create a random score for a given subj in a given trial
            test.Subj(ii).tr(jj).rt_raw = test.Subj(ii).tr(jj).rt_square*data.parameters.task.score_ratio;
            test.Subj(ii).tr(jj).rt_rounded = round(test.Subj(ii).tr(jj).rt_raw,2);

            %transfo rt en score
            [~,test.Subj(ii).tr(jj).column_fction_score] = ismembertol( test.Subj(ii).tr(jj).rt_rounded,data.fction_score(1,:),0.001); % Get column corresponding to the rt_rounded 
            test.Subj(ii).tr(jj).Score = data.fction_score(2,test.Subj(ii).tr(jj).column_fction_score); % Copy-paste from fction_score to Subj matrix
        end
    end
        for jj = 1:5
            data.run.trial(jj).score_oth = [test.Subj(1).tr(jj).Score,...
                test.Subj(2).tr(jj).Score,test.Subj(3).tr(jj).Score,...
                test.Subj(4).tr(jj).Score];
        end
end

