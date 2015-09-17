%% EstimateDistanceIntegration.m demo example.
%
% This example uses the accelerometer to estimate distance travelled. 
% Function returns acceleration in [x,y,z] directions. Unit is [G=10m/s^2] 
% We only use x-axis on the accelerometer for calculation. Make sure
% that the Engduino device is placed with the LEDs facing downwards. Upload
% the code, position the accelerometer, press the button to start and press the
% button to stop the calculation immediately.
%
% July 2015, Engduino team: support@engduino.org
 
%% Initialize variables
% Check if the Engduino object already exists. Otherwise initialize it.
if (~exist('e', 'var'))
    % Create Engduino object and open COM port. You do not need to select
    % an active COM port, as it should be detected automatically. However,
    % in the case of unsuccessful connection, you may initialize Engduino
    % object with passing the active COM port. E.g. e = engduino('COM8');
    % To open the 'Bluetooth' port you need to initialize the Engduino
    % object with the 'Bluetooth' keyword and your Bluetooth device name.
    % E.g. e = engduino('Bluetooth', 'HC-05'); Demo mode can be enabled by
    % initialize the Engduino object with 'demo' keyword. E.g. e =
    % engduino('demo');
    e = engduino('Bluetooth','HC-05');
end

% Set reading frequency [Hz] - readings per second.
frequency = 100;

% Set multiplier to convert accelerometer data to acceleration m/s^2
multiplier = 26;

% Set threshold to ignore small noise in acceleration 
acc_threshold = 0.5;

% initialise filtered value to 0
xAcc_Filtered = 0;
acceleration_Filtered=0;
velocity_Filtered =0;

% coefficient to apply filtering
alpha = 0.5;
beta = 0.9;
gamma = 0.9;

% Initialise variables for calculation
previous_time =0;
previous_velocity =0;
total_displacement = 0;
current_velocity = 0;
current_time = repmat(now, 2, 4);


%% For Graph plotting
buffSize = 10;
accelerometer_circBuff = nan;
acceleration_circBuff = nan;
time = now;
t0 = now;
i=1;

figure;

graph(1) = subplot(1,2,1);
graph(2) = subplot(1,2,2);
% graph1
subplot(graph(1));
plotHandle1 = plot(graph(1),time,accelerometer_circBuff,'Marker','o','MarkerSize',5,'LineWidth',2);
xlabel('Time[s]');
ylabel('Gravitational Force (g)');
title(['Acceleration: ' char(vpa(acceleration_Filtered,3)) 'm/s^2']);
axis square;
grid on

% graph2
subplot(graph(2));
plotHandle2 = plot(graph(2),time,acceleration_circBuff,'Marker','o','MarkerSize',5,'LineWidth',2);
xlabel('Time[s]');
ylabel('Gravitational Force (g)');
title(['Acceleration: ' char(vpa(acceleration_Filtered,3)) 'm/s^2']);
axis square;
grid on

% Wait to start calculation
while(not(e.getButton()))
    pause(0.1);
end

pause(0.3);

%% Initialise accelerometer reading
for i=1:5
    newReading = e.getAccelerometer();
    gx = newReading(1);
    % apply high pass filter to the accelerometer output
    xAcc_Filtered = gx - ((1-alpha)*xAcc_Filtered + alpha*gx);
end

% accelerometer data is multiplied to get 1g=10m/s^2
init_accx = (floor(xAcc_Filtered*100)*multiplier/100); 

%% Main Program loop
while (not(e.getButton()))
    % Read acceleration vector from Engduino's accelerometer sensor.
    newReading = e.getAccelerometer();
    gx = newReading(1);
    % apply high pass filter to the accelerometer output
    xAcc_Filtered = gx - ((1-alpha)*xAcc_Filtered + alpha*gx);

    acceleration = (floor(xAcc_Filtered*100)*multiplier/100 - init_accx);
    
    % low pass filter to filter out noise from calculated acceleration
    acceleration_Filtered = (1-beta)*acceleration_Filtered + beta*acceleration;
    % ignore small value acceleration due to noise
    if(acceleration_Filtered>-acc_threshold&&acceleration_Filtered<acc_threshold)
        acceleration_Filtered = 0;
    end
    
    current_time = repmat((now - t0)*10e4,1,1);
    
    x=sym(acceleration_Filtered);
    
    % Calculate distance
    current_velocity = previous_velocity + int(x, previous_time, current_time);
    
    % low pass filter to filter out noise from calculated velocity
    velocity_Filtered = (1-gamma)*velocity_Filtered + gamma*current_velocity;

    % double integration from accelerometer to displacement
    displacement = int(current_velocity, previous_time, current_time);
    
    total_displacement = total_displacement + displacement;
    previous_velocity = velocity_Filtered;
    
    previous_time = current_time;
    
    
    
    if i < buffSize
        % Add the newest sample into the buffer.
        accelerometer_circBuff(i) = gx;
        acceleration_circBuff(i) = xAcc_Filtered;
        time(i) = (now-t0)*10e4;
    else
        % If we have enough samples then remove oldest sample and add the
        % newest one into the buffer.
        accelerometer_circBuff = [accelerometer_circBuff(2:end), gx];
        acceleration_circBuff= [acceleration_circBuff(2:end), xAcc_Filtered];
        time = [time(2:end), (now - t0)*10e4];
    end
    % subplot raw X acceleration vector
    subplot(graph(1));
    limits = 1.0;
    xlim([min(time) max(time)+10e-9]);
    ylim([-limits limits]);
    title(['Acceleration: ' char(vpa(acceleration_Filtered,3)) 'm/s^2']);
    set(plotHandle1,'YData',accelerometer_circBuff,'XData',time);
    
    
    subplot(graph(2));
    limits = 1.0;
    xlim([min(time) max(time)+10e-9]);
    ylim([-limits limits]);
    title(['Acceleration: ' char(vpa(acceleration_Filtered,3)) 'm/s^2']);
    set(plotHandle2,'YData',acceleration_circBuff,'XData',time);
%     % subplot filtered X acceleration vector
%     subplot(1,2,2)
%     cla;
%     line([0 xAcc_Filtered], [0,0],'Color', 'r', 'LineWidth' , 2, 'Marker', 'o');
%     % limit plot to +/- 1.25g in all directions and make axis square
%     limits = 2.5;
%     axis([-limits limits -limits limits]);
%     axis square;
%     grid on
%     xlabel('X-axis acceleration (filtered)')
% 
%     
%     title(['Distance Travelled: ' char(vpa(total_displacement,3)) 'm']);
%     drawnow;

    % Pause for one time interval.
    pause(1/frequency);
    
    i = i+1;
    
end