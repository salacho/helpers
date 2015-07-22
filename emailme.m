function emailme(youremail,password,emailmain,emailtxt,emailto,attfile)
% function emailme(youremail,password,emailmain,emailtxt,emailto)
%
% This function setups the smtp server and other preferences properties in
% order to send an e-mail in Matlab. 
% 
% Common usage: emailme(youremail,password,emailmain,emailtxt)
% 
% It requires the e-mail 'password' in order to use your account to send the
% message. If not included, Matlab looks for it in Windows in case it is 
% stored in the web browser. By default the recipient is also your 'myemail'. 
% It could be changed using 'emailto' optiopn.
% 
% Input:
%
% youremail: String file with one e-mail or cell file with various e-mails. If a 
%            cell structure the first e-mail should be the sender's (whos 
%            password is included below) youremail =
%            {'salacho1@gmail.com','myPIemail@unicef.org'}
% password: String. Sender's e-mail password. 
% emailmain: String. subject of the e-mail (header).
% emailtxt: String included in the message. 
% emailto: e-mail of the recipient. By default is 'youremail'.
% attfile: Always a cell with the path to the file or files of interest 
%          {'C:\\AndresFiles\examples\Figure.png','Sygnals&SystemsFinal.doc'}
%
% Output: 
%
% Check you e-mail/s.
%
% Created by Andres Salazar (salacho) 10 March 2012
% salacho@bu.edu, salacho@mit.edu
% Last modififed 6 April 2012
 
if iscell(youremail)
    sourcemail = youremail{1};
else
    sourcemail = youremail;
end

% Setting up the e-mail smtp server
% For GMail use 'smtp.gmail.com'. For others check with service provider.
[~,smtp] = strtok(sourcemail,'@');
smtp = ['smtp.',smtp(2:end)];

if nargin <= 4 
    emailto = youremail;
end
    
if nargin <= 2
    emailmain = 'A lovely message from your Matlab code';
    emailtxt = 'No text was included but the message will be sent anyway; have a nice day!!'; 
end

% Setting up the send e-mail preferences
setpref('Internet','E_mail',sourcemail);
setpref('Internet','SMTP_Server',smtp);
setpref('Internet','SMTP_Username',sourcemail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% Sending e-mail
if nargin <= 5 
    sendmail(emailto,emailmain,emailtxt);
else
    pp = 0;
    np = 0;
    noatt = '';
    for kk = 1:length(attfile)
        filex = exist(attfile{kk},'file')/2;
        pp = pp + filex;
        if filex
            att_tosend{pp} = attfile{kk};
        else
            np = np + 1;
            noatt = [noatt,'; ',char(attfile{kk})];
        end
    end
    if pp == length(attfile)
        sendmail(emailto,emailmain,emailtxt,att_tosend);
        disp('Sent all attachments.')
    elseif np == length(attfile)
        sendmail(emailto,emailmain,[emailtxt,'. No attachments were included due to a problem with the name or the path. These are the files:',noatt(2:end)]);
        disp('No attachments sent.')
    else
        sendmail(emailto,emailmain,[emailtxt,'. Some files were not attached due to a problem with the name or the path:',noatt(2:end)],att_tosend);
        disp('Only some attachments sent.')
    end
end
 
