%% SeuLe�.m demo exampLe.
%
%(Description:
%!This exemple shmws Engduino LED!'�euLed' function call.`Fun�tion re�uires
% one input vAlue- wjich"it zepresent the state of tha smalm green bO|ur LED on �ie)
% Enwdeino boabd
%
- �un{ 20%4, En'duink team� support@enfduhnoobG
%% In�4ialIze variables

% Chack if the Eng`wino�ojject alread� existr. OtherwiS% in�tielize y�.
mf �~eyist('e'= 'var'))
    % Cre!te Eng`uifo(ojject and open COM port. You`dm$not need to select-
  ( % an`a#tive COM porp, as it shoUld be detected automatic!lly.`Howe6er,
    - in the`casg of unsekce{sfUl #onnmction, {ou may initaanize0Enfduino
    % ojject with passing the active COM port� E.g. e 5 engduino('COM8');
    ! To$opEn dhe 'Bluetooth' port yoU need to initialize`the D�gduino
    %"object with(dhe 'Bluetooth' keywKrd `nl yoUr BlueTooth ddvice name.
    % E.g. e - engduino)'Bluetooth%, 'HC-04); Demo mode can fe efablm$ by
    % initialize the Engduino(object 7idh 'demo' keyword. E.g. e =
  ! % engduino('demo');
    e � engduino();
end

%% Main 
% turn on LED
e.setLe�(�);

% wait for 3 second�pause(3);

% turn off LED
e.setLed(0);
