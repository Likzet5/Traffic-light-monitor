function  [gront_rott, Knapp] =Reader_device
%close all; clear all;

deviceReader = audioDeviceReader(44100,48000);
setup(deviceReader)

fileWriter = dsp.AudioFileWriter('mySpeech.wav','FileFormat','WAV');

gront_rott = false;
Knapp = false;

disp('Speak into microphone now.')

gront_counter=0;
knappcounter=0;

tic
while toc < 40 % Spelar in i 40s
    
     acquiredAudio = deviceReader();
    % filterAA = bandpass(acquiredAudio,[3950 4050],44100);
     
     filterAA = Band_pass(acquiredAudio,3950);
     %filterKnapp = bandpass(acquiredAudio,[4750 4850],44100);
     filterKnapp = Band_pass(acquiredAudio,4750);

     Knapp_Sum = sum(filterKnapp>0.1);
     if Knapp_Sum>400
         Knapp = true
         knappcounter=knappcounter+1;
     
     else 
         Knapp = false
     end
     
     gront_rott_Sum = sum(filterAA>0.1);
     if gront_rott_Sum>2500
         gront_rott = true
         gront_counter=gront_counter+1;
     
     else 
         gront_rott=false
     end
     %for(fil)
     %plot(filter);
   %  drawnow();
    fileWriter(acquiredAudio);
    
end
disp('Recording complete.')

release(deviceReader)

%     t = tiledlayout(2,1);
%     plot([0:gront_counter],'-x');  hold on;
%     plot([0:knappcounter],'-o'); hold off;
    
release(fileWriter)
end

