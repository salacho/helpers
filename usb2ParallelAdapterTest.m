function usb2ParallelAdapterTest
% function usb2ParallelAdapterTest
%
% Test the USB 2 Parallel adapter is actually doing its job, from
% serial to parallel communication conversion. 
%
%
% 
% Andres    : v1    : init. 18 March 2015

% Find available serial/USB ports
avalPorts = instrhwinfo ('serial');
%avalPorts.SerialPorts;  % name of the port

dataIO = serial('com3','BaudRate',256,'DataBits',8);
%dataIO = serial('com3','BaudRate',32,'DataBits',8);
%dataIO = serial(avalPorts.SerialPorts)

%% Open the port to be used, make it read/writable
fopen(dataIO);

%% Test writting to port (codes sent by Baxter)

for iVal = 1:255

    val2Write = [1 1 1 1 0 0 0 0];      % need to check there is no inversion of the bits (high values of the word are indeed the right-most bits)
    val2Write = [0 0 0 0 1 1 1 1];      % need to check there is no inversion of the bits (high values of the word are indeed the right-most bits)
    fwrite(dataIO,val2Write) 


end
%% Test reading to port (classifier's outcome sent to Baxter)


baxerCode = fread(dataIO)



%% Close port, release it 
fclose(dataIO);


end