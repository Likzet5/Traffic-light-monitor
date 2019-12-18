function [filtered_signal] = Band_pass(data, passfilter)
N = length(data);
Fs = 44100;                                                  % Sampling Frequency (Hz)
Fn = Fs/2;                                                  % Nyquist Frequency (Hz)
Wp = [passfilter   passfilter+100]/Fn;                                         % Passband Frequency Vector (Normalised)
Ws = [passfilter-1    passfilter+101]/Fn;                                         % Stopband Frequency (Normalised)
Rp =   1;                                                   % Passband Ripple (dB)
Rs = 150;                                                   % Stopband Ripple (dB)
[n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);                             % Filter Order
[z,p,k] = cheby2(n,Rs,Ws);                                  % Filter Design
%[sosbp,gbp] = zp2sos(z,p,k);                                % Convert To Second-Order-Section For Stability
%figure(3)
%freqz(sosbp, 2^16, Fs) % Filter Bode Plot
sosbp = load('sosbp_file.mat','sosbp');
gbp = load('gbp_file.mat','gbp');
filtered_signal = filtfilt(sosbp.sosbp, gbp.gbp, data);    % Filter Signal

end

