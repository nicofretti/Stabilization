% Mercoledi' 20 Gennaio 2021
% Corso di Elaborazione dei Segnali e Immagini
% Docente: Ilaria Boscolo Galazzo
% Docente coordinatore: Marco Cristani
% Assistente: Christian Joppi


%% Esercizio 1 - Rimozione specifiche frequenze tramite filtri ferma-banda
% Rimuovere dall'immagine "cameraman.tif" il rumore sinusoidale aggiunto attraverso un 
% opportuno filtro ferma-banda. 

clear all
close all
clc

% Carico immagine selezionata
I = imread('cameraman.tif');
I = double(I);
[M,N] = size(I);

% Applico rumore
xCoords = linspace(1,256,256);
yCoords = xCoords';
noise = -sin(xCoords*1.5)-sin(yCoords*1.5);
I = I + 25*noise;

figure, imagesc(I);

% 1. Creare il padding (funzione padarray)


% 2. Calcolare la DFT dell'immagine appena creata e applicare lo shift (fftshift)


% 3. Generare un filtro ferma-banda di Butterworth (funzione bbsf)


% 4. Eseguire la moltiplicazione tra filtro e il risultato della DFT 


% 5. Ricostruire l'immagine tramite FFT inversa e ricentratura (immagine
% di dimensione PxQ) (funzione ifftshift per la ricentratura)


% 6. Rimozione del padding, in modo da tornare ad una immagine di
% dimensioni MxN


% 7. Visualizzare graficamente tutte le fasi del filtraggio

figure;
subplot(2,2,1);imshow(uint8(I));title('Original image');
subplot(2,2,2);imshow(uint8(Ipad));title('Padding');
subplot(2,2,3);imshow(log10(1+abs(him)),[]); title('Fourier Transform');
subplot(2,2,4);imshow(uint8(rim),[]);title('Filtered image');


%% Esercizio 2 - Analisi delle tessiture, dove si trova il difetto? 
% Utilizzare in combinazione filtro passa-basso e metodo di otsu per
% ottenere la porzione di tessitura danneggiata. 

clear all
close all
clc

I = rgb2gray(imread('texture.jpg'));
[M,N] = size(I);

% 1. Analizzare l'output della binarizzazione di Otsu direttamente
% sull'immagine non filtrata

% Troppe alte frequenze! Proviamo a toglierle con un filtro passa-basso!
I = double(I);
imagesc(I);

% 2. Creare il padding

% 3. Calcolare la DFT dell'immagine appena creata

% 4. Generare un filtro passa-basso Gaussiano

% 5. Eseguire la moltiplicazione tra filtro e il risultato della
% DFT 

% 6. Ricostruire l'immagine tramite FFT inversa e ricentratura (immagine
% di dimensione PxQ)

% 7. Rimozione del padding, in modo da tornare ad una immagine di
% dimensioni MxN


% 8. Attraverso il metodo di Otsu, binarizzo l'immagine e cerco il difetto
% nella texture

I_highlight =  cat(3, I, I, I);
[rr,cc] = ind2sub(size(BW),find(BW==0));
for i=1:numel(rr)
    I_highlight(rr(i),cc(i),1:3)=255;
    I_highlight(rr(i),cc(i),3)=0;
end

% Visualizzazione dei risultati
figure;
subplot(2,3,1);imshow(uint8(I));title('Original image');
subplot(2,3,2);imshow(uint8(Ipad));title('Padding');
subplot(2,3,3);imshow(log10(1+abs(him)),[]); title('Fourier Transform');
subplot(2,3,4);imshow(uint8(rim),[]);title('Filtered image');
subplot(2,3,5);imshow(uint8(BW),[]);title('Binarized image');
subplot(2,3,6);imshow(uint8(I_highlight),[]);title('Original Image with defects highlighted');


%% Esercizio 3 - Stabilizzazione video
% Attraverso la cross-correlazione, stabilizzare il video! 
% (Hint: selezionare la parte in movimento che viene mostrata per tutto il video, qualche macchina?)

clear all
close all
clc

vid = VideoReader('shaky_car.avi');
nFrames = vid.NumFrames;

firstFrame = vid.readFrame();
[R,C,~] = size(firstFrame);

% 1. Trovare la parte in movimento sempre presente nel video e farne il crop
%  (una delle macchine?)
figure; template = imcrop(firstFrame);
template = rgb2gray(template);
[tR,tC] = size(template);

% 2. Stabilizzo i vari frames
for i = 1:nFrames-1
    frame = vid.readFrame();
    frames(:,:,:,i) = frame;
    frame_gray = rgb2gray(frame);
    cc = normxcorr2(template,frame_gray);
    [max_cc, imax] = max((cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [(ypeak-size(frame,1)) (xpeak-size(frame,2))]
    
    new(:,:,:,i) = imtranslate(frame,[-(corr_offset(2)+round(C/2)),...
        -(corr_offset(1)+round(R/2))],'FillValues',0);
    ccs(:,:,i) = cc;
    
    subplot(221); imagesc(template); axis image; title('Template scelto');
    subplot(222); imagesc(frame_gray); axis image;  title(strcat('Immagine originale: ', num2str(i)));
    subplot(223); imagesc(ccs(:,:,i)); colorbar; title('Mappa di cross-correlazione 2D');
    hold on;      scatter(xpeak, ypeak,'rX');
    subplot(224); imshow(new(:,:,:,i)); title('Immagine stabilizzata');

    i
    pause(0.025)
    
end

%
vidObj = VideoWriter('stabilized_video.mp4');
open(vidObj);
figure;
for i=1:size(frames,4)
    subplot(121); imshow(frames(:,:,:,i));
    subplot(122); imshow(new(:,:,:,i));
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
end 
   close(vidObj);


%% Esercizio 4 - Segnali cerebrali - Smoothing e mappe di correlazione
% Il file denominato "fMRI_original.nii.gz" contiene i segnali fMRI registrati in 
% un soggetto sano in condizioni di riposo. In particulare, e' presente una
% singola "fettina" (slice), che e' stata campionata nel tempo per piu'
% istanti, piu' precisamente 260 volte. 

% Una volta caricato il dato:
%   1. eseguire un'operazione di smoothing gaussiano, con dimensione = 3 e sigma massimo. Visualizzare in un'unica
%   figura il primo istante (volume), prima e dopo lo smoothing;
%   2. caricare il file "mask.nii.gz" ed estrarre il segnale medio per questa regione --> questo diventera'
%   il nostro segnale di riferimento, che chiameremo "segnale seed" e avra' dimensione 260x1 (visualizzarlo);
%   3. calcolare la correlazione (zero-lag) tra il segnale seed e il segnale di ciascun
%   altro voxel, ottenendo quindi una mappa di correlazione (visualizzarla); 
%   4. sogliare la mappa di correlazione ottenuta a 0.2, ponendo a 0 tutti
%   i valori inferiori a questa. Visualizzare la nuova mappa sogliata 

filename = 'fMRI_original.nii.gz';
nii = load_untouch_nii(filename);
data = double(nii.img); 
[nr,nc,nt] = size(data);

filename = 'mask.nii.gz';
nii = load_untouch_nii(filename);
mask = double(nii.img); 

% 1. Smoothing gaussiano, dimensione 3 e sigma massimo 


% 2. Estrarre il segnale medio utilizzando la maschera data (output: 260x1)


% 3. Calcolare la correlazione tra segnale seed e ogni altro voxel,
% ottenendo una mappa di correlazione. Visualizzarla 


% 4. Sogliare la mappa di correlazione a 0.2, ponendo a 0 tutti
% i valori inferiori a questo valore. Visualizzarla



%% Esercizio 5 - Segnali cerebrali - Filtraggio in frequenza 
% Il file denominato "Control_data.txt" contiene i segnali fMRI medi (260
% campioni per ognuno di essi), estratti da 200 regioni cerebrali in un soggetto a riposo. 

% Una volta caricato il dato:
%   1. prendere il segnale della regione 112, visualizzarne l'andamento nel
%   tempo e il suo spettro di ampiezza; 
%   2. eseguire per ciascun segnale un'operazione di filtraggio in frequenza di tipo
%   passa-basso, con cut-off a 0.1 Hz (hint: usare il comando 'lowpass', con 'ImpulseResponse','iir');
%   3. calcolare per ogni coppia di segnali la correlazione (a zero-lag); 
%   4. calcolare per ogni coppia di segnali la coerenza, e si medi su tutte quante le frequenze a disposizione 
%   per ottenere una matrice media (hint: usare il comando 'mscohere', nel seguente modo: mscohere(S1',S2',[],[],[],fs));
%   5. visualizzare la matrice di correlazione e quella media di coerenza
%   in un'unica figura

data = importdata('Control_data.txt');
[nr,nc] = size(data);

%  1. Segnale della regione 112: visualizzazione nel tempo e frequenza
TR = 2.02;
fs = 1/TR;
fsmax = fs/2;
signal = data(:,112);
N = nr;
frequency = [0:fs/N:fsmax]';
NumUniquePts = ceil((N+1)/2);
Spectrum_raw = fft(signal);
Spectrum_raw = Spectrum_raw(2:NumUniquePts);
Spectrum_raw = [0;Spectrum_raw];
figure, subplot(121), plot([1:260], signal), title('Segnale Tempo'), xlim([0 260])
subplot(122),plot(frequency, abs(Spectrum_raw)), title('Spettro ampiezza')

% 2. Operazione di filtraggio passa-basso con lowpass.m e cut-off di 0.1
% Hz. Visualizzo il segnale filtrato della regione 112 (tempo e frequenza)


% 3. Calcolare la correlazione tra ogni coppia di segnali filtrati


% 4. Calcolare la coerenza tra ogni coppia di segnali filtrati e medio su
% tutte le frequenze a disposizione


% 5. Visualizzare le matrici di correlazione e di coerenza


%% Esercizio 6 - Filtraggio immagini nel dominio dello spazio 
% Data l'immagine "Flower.png", corrotta da rumore gaussiano, applicare gli
% operatori locali/puntuali che si ritengono piu' adatti per il
% miglioramento dell'immagine stessa. Utilizzare, se necessario, anche
% operatori in successione. 


%% Esercizio 7 - Segmentazioni immagini 
% Data l'immagine "Retina.tif", applicare opportuni filtraggi sia nel
% dominio dello spazio che delle frequenze per estrarre i vasi sanguigni
% dall'immagine della retina e confrontare con l'immagine gia' segmentata
% fornita, che rappresenta il ground truth di riferimento. 
% In particolare, come operazione di filtraggio in frequenza si consiglia
% di applicare un filtro passa-banda di butterworth, la cui risposta in frequenza puo'
% essere descritta come moltiplicazione di un filtro passa alto con un
% filtro passa basso. In maniera analoga, si puo' descrive come Hband = 1-Hrej_band (si veda
% Esercizio 1). 
% Immagini da: https://github.com/gautamkumarjaiswal/reitna-segmentation/tree/master/retina_images

% 1) Carico immagine selezionata
I = rgb2gray(imread('Retina.tif'));
I = double(I);
I = imresize(I,.8);

% 1bis) Filtraggi nel dominio dello spazio


% 2) Filtraggi nel dominio delle frequenze: operazione di padding, ricordando che tipicamente P = 2M, Q = 2N.


% 3) Eseguo l'analogo dell'fftshift ma nello spazio 


% 4) Calcolo la DFT dell'immagine appena creata al punto 3 


% 5) Genero un filtro passa-basso di butterworth, centrato in (P/2,Q/2): 
n = 1; % ordine del filtro di Butterworth
thresh = 130; % raggio. Testare come cambia il risultato al variare di questo valore

% PASSA BASSO


% PASSA ALTO 


% PASSA BANDA


% 6) Eseguo la moltiplicazione tra filtro al punto 5 e con risultato della DFT al punto 4 


% 7) Ricostruisco l'immagine tramite FFT inversa e ricentratura (immagine di dimensione PxQ)


% 8) Rimozione del padding, in modo da tornare ad una immagine di dimensioni MxN


% 9) Visualizzare graficamente tutte le fasi del filtraggio:

figure;
subplot(2,3,1);imshow(uint8(I));title('Original image');
subplot(2,3,2);imshow(uint8(Ipad));title('Padding');
subplot(2,3,3);imshow(uint8(Ipad_center)); title('Transform centering');
subplot(2,3,4);imshow(log10(1+abs(him)),[]); title('Fourier Transform');
subplot(2,3,5);imshow(uint8(ifim),[]);title('Inverse Fourier transform with padding');
subplot(2,3,6);imshow(uint8(rim),[]);title('Filtered image');

% 10) Ulteriore pulizia nel dominio dello spazio (se necessario) 


% 11) Segmentazione per ricavare i vasi e confronto con immagine Ground Truth 

gt1 = imread('Gtruth_1.tif');
gt1 = imresize(gt1,.8);
