function [Resp, RT] = collectResponse(varargin)
% collectResponse.m
%
% Author: Cendri Hutcherson
% Date: 1.27.09
%
% Description: Waits a specified amount of time for subject to respond,
% records response and RT.
%
% USAGE: collectResponse([waitTime],[moveOn],[allowedKeys])
% 
% EXPLANATION: defaults to infinite waitTime, moving on as soon as any
% button is pressed [i.e. moveOn = 1], with any key press triggering the
% move.  If you wish the program to wait out the remainder of the waitTime
% even if a key has been pressed, use moveOn = 0.  If you wish the program
% to accept as input only certain keys, enter the allowed keys as a string
% (e.g. '12345' or 'bv')

% Set defaults and initialize variables
ListenTime = Inf;
moveOn = 1;
allowedKeys = [];
StartWaiting = GetSecs();
Resp = 'NULL';
RT = NaN;
chose = 0;
multiResponse = [];
multiRT = [];

if length(varargin) >= 1
    ListenTime = varargin{1};
end

if isempty(ListenTime); ListenTime = Inf; end

if length(varargin) >= 2
    moveOn = varargin{2};
end

if isempty(moveOn); moveOn = 1; end

if length(varargin) >= 3
    allowedKeys = varargin{3};
end

if length(varargin) >= 4
    inputDevice = varargin{4};
end

if ListenTime == Inf && moveOn ~= 1
    error('Infinite loop: You asked me to wait forever, even AFTER the subject has responded!')
end

% Start queue
KbQueueCreate(inputDevice);
KbQueueStart(inputDevice);

if isempty(allowedKeys)
    while (GetSecs() - StartWaiting) < ListenTime
        [pressed, firstPress] = KbQueueCheck(inputDevice);
        if pressed
            if chose == 0
              RT = firstPress(find(firstPress)) - StartWaiting;
              RespKey = KbName(find(firstPress));
              Resp = RespKey(1);
            elseif chose == 1
              multiResponse = [multiResponse Resp];
              multiRT =[multiRT RT];
              RT = firstPress(find(firstPress)) - StartWaiting;
              RespKey = KbName(find(firstPress));
              Resp = RespKey(1);
            end
            chose=1;
        end
    end    
else
    while (GetSecs() - StartWaiting) < ListenTime
        [pressed, firstPress] = KbQueueCheck(inputDevice);
        if pressed
            if chose == 0
              RT = firstPress(find(firstPress)) - StartWaiting;
              RespKey = KbName(find(firstPress));
              Resp = RespKey(1);
              if ~any(allowedKeys==Resp)
                  Resp = 'NULL';
                  RT = NaN;
              end
            elseif chose == 1
              multiResponse = [multiResponse Resp];
              multiRT =[multiRT RT];
              RT = firstPress(find(firstPress)) - StartWaiting;
              RespKey = KbName(find(firstPress));
              Resp = RespKey(1);
              if ~any(allowedKeys==Resp)
                  Resp = 'NULL';
                  RT = NaN;
              end
            end
            chose=1;
        end
    end    
end

if moveOn ~= 1
    while (GetSecs() - StartWaiting) < ListenTime
    end
end
