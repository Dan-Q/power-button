# Power Button

Experimental tool for triggering command execution across a network. Part of a project to build a "big red button" which, when pressed, will lock _all_ of my computers (which run a variety of operating systems).

## Usage example

### Listener (server)

One or more computers _listen_ for a signal across the network, and then execute a specified command. The syntax is:

`./power-button.rb listen [secretkey] [port] [command]`

For example, to sleep the display on a MacOS computer when a signal is received on (UDP) port 12345 which is signed with the secret key `21f696ccadddad1963a55ffa748417855c3`, you might run:

`./power-button.rb listen 21f696ccadddad1963a55ffa748417855c3 12345 pmset displaysleepnow`

Different listeners may listen for the same signal but run different commands; this allows e.g. you to have listeners running different operating systems that perform functionally-similar (but differently-implemented) functions.

### Controller

Another computer can send the signal to one or more listeners. Configure the controller with the following syntax:

`./power-button.rb control [secretkey] [port] [targets]`

The secret key and port must be the same on both the listener(s) and any controller(s); unmatching signals will be rejected. The signal is sent every time the enter key is pressed on the controller (it's assumed that you've built your own "enter key" button that activates the signal).

For example, to send a signal to the MacOS computer described above (which we'll assume is at IP address 192.168.1.2), while simultaneously sending the same signal to the computer at domain name mycomputer.local, you might run the following (and then press the enter key every time you want the signal sent):

`./power-button.rb control 21f696ccadddad1963a55ffa748417855c3 12345 192.168.1.2 mycomputer.local`

## Demonstration

For a simple demonstration of use, try running:

`./power-button.rb listen mysecretkeywillgohere 12345 echo message received`

Then in another window, run:

`./power-button.rb control mysecretkeywillgohere 12345 localhost`

Every time you press enter in the second window, the first window should say "message received".

## Troubleshooting

Note that the system clocks need to be synchronised for this to work; a drift of up to 30 seconds is tolerated.

## Future work?

Replay attacks are possible within the clock drift window (30 seconds). This could be mitigated by retaining a log of received messages (or their signatures) and rejecting duplicates.

A possible future enhancement would allow for multiple commands to be managed and separately triggered.

It'd be nice to be able to store configuration and particularly secret keys in a configuration file.
