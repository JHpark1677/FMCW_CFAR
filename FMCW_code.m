close all
clear all
clc

parameter0 % parameter file 업로드, mmwavestudio에서 설정한 radar parameter들에 맞게 수정

filename='C:\Users\RTL\Desktop\레이더 스터디\2주차\code\data.bin'; %file directory 및 이름 입력
data = readDCA1000(filename,numADCsamples); % readDCA1000함수를 통해 레이더에서 출력된 binary file을 matrix로 변환
numVirtualAnt
total_data = zeros(numFrames,numAntennas,numChirps*numTx,numADCsamples); 
for frameidx = 1:numFrames
    for antidx = 1:numAntennas
        for chirpidx = 1:numChirps*numTx
            total_data(frameidx,antidx,chirpidx,:) = data(antidx, numADCsamples*numChirps*numTx*(frameidx-1) + (chirpidx-1)*numADCsamples + 1 ...
                                                                : numADCsamples*numChirps*numTx*(frameidx - 1) + chirpidx*numADCsamples);
        end
    end
end
Tx1SentData=zeros(numFrames,numAntennas,numChirps,numADCsamples);
for frameidx = 1:numFrames
    for antidx = 1:numAntennas
        for chirpidx = 1:numChirps
            Tx1SentData(frameidx,antidx,chirpidx,:)=total_data(frameidx,antidx,chirpidx*numTx-1,:);
        end
    end
end

correction=20*log10(2.^15)+10*log10(256*128)-20*log10(sqrt(2))-10; % 단위를 dBm으로 맞추기 위함, plot할때 correction진행 예정
%%

frameidx = 71;    % set frame index to observe
antidx = 1;    % set antenna index to observe

dataused_rv = squeeze( total_data(frameidx,antidx,1:2:255,:));    % 128*256 matrix
dataused_rv = fft2(dataused_rv);
dataused_rv = fftshift(dataused_rv,1);    % switch upper-half/lower-half
Raxis = 0:Rres:Rres*(numADCsamples-1);
vaxis = -vres*(numChirps/2):vres:vres*(numChirps/2-1);
vaxis=vaxis/numTx;
figure()
mesh( Raxis,vaxis,mag2db(abs(dataused_rv))-correction) % Doppler target(ex. human) shows significant peak
colormap(jet)
xlim([Raxis(1),Raxis(end)/2])    % ignore half of the range-FFT data
ylim([vaxis(1),vaxis(end)])
title('Range-velocity estimation (FFT)')
xlabel('Range (m)')
ylabel('Velocity (m/s)') 
zlabel('Magnitude (dB)')
set(gca,'YDir','normal')
caxis([-80 -20]);
box on

%% cfar 여기서부터 작성하시면 돼요!
guard = 2;
N_g=10;
S_ca = 8; % 수정
image=zeros(numChirps+2*N_g,numADCsamples+2*N_g);

Index_Peak2=zeros(size(dataused_rv));
Threshold2=zeros(size(dataused_rv));

image(N_g+1:numChirps+N_g,N_g+1:numADCsamples+N_g)=dataused_rv;
for n=1:numChirps+2*N_g 
    for m=1:numADCsamples+2*N_g
        if n<=N_g
            temp1=1;
        elseif n>numChirps+N_g
            temp1=-1;
        else
            temp1=0;
        end
        if m<=N_g
            temp2=1;
        elseif m>numADCsamples+N_g
            temp2=-1;
        else
            temp2=0;
        end
        image(n,m)=dataused_rv(n-N_g+numChirps*temp1,m-N_g+numADCsamples*temp2).*conj(dataused_rv(n-N_g+numChirps*temp1,m-N_g+numADCsamples*temp2));
    end
end

for v_dir = 1:numChirps
    for r_dir = 1:numADCsamples
        temp = 0;
        for w_1 = 0:2*N_g
            for w_2 = 0:2*N_g
                temp = temp + abs(image(v_dir+w_1, r_dir+w_2));
            end
        end

        for w_3 = 0:guard*2
            for w_4 = 0:guard*2
                temp = temp - abs(image(v_dir+N_g-guard+w_3, r_dir+N_g-guard+w_4));
            end
        end

        temp = temp/((2*N_g+1)^2-(2*guard+1)^2);
        Threshold2(v_dir, r_dir) = temp * S_ca;
        if abs(image(v_dir+N_g, r_dir+N_g)) > Threshold2(v_dir, r_dir)
            Index_Peak2(v_dir, r_dir) = 1;
        else
            Index_Peak2(v_dir, r_dir) = 0;
        end
    end
end

figure()
mesh(Raxis,vaxis,Index_Peak2);
xlim([Raxis(1),Raxis(end)])    % ignore half of the range-FFT data
ylim([vaxis(1),vaxis(end)])
title('Index_Peak2')
xlabel('Range (m)')
ylabel('Velocity (m/s)') 
zlabel('Magnitude (dB)')
set(gca,'YDir','normal')
box on

figure()
mesh(Raxis,vaxis, Threshold2);
xlim([Raxis(1),Raxis(end)])    % ignore half of the range-FFT data
ylim([vaxis(1),vaxis(end)])
title('Threshold2')
xlabel('Range (m)')
ylabel('Velocity (m/s)') 
zlabel('Magnitude (dB)')
set(gca,'YDir','normal')
box on