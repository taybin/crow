# Crow

A messaging language superset of Icon

## Overview

Crow takes the actor model as implemented by [MDC-90](https://dl.acm.org/citation.cfm?id=67405) and adds it to [Icon](https://www2.cs.arizona.edu/icon/index.htm).

### Structure

With Crow, you define classes with behaviors. You can think of behaviors as anonymous functions defined entirely by their arguments. The arguments are messages, which is a special type defined earlier. Each instance of the class has an message queue and each message has a number of named fields. Events in the queue are then matched against each behavior until one is found that will match it. If you have used Erlang, this should sound familiar to you.

#### Hello World

```icon
message print(text)

class OUTPUT
behavior(print p1)
    write(p1.text || " " || here.X)
end

procedure main()
    bottle := print("Hello World")
    s := symbol("OUTPUT")
    every i := 1 to 3 do
	send(bottle, <s,i>)
end
```

#### Other examples

There are other examples for simple problems like generating primes and fibanocci sequences. I am not able to explain how they work. The implementations were transcribed from MDC-90 examples, and they ran and had the correct results, but in 2000 I had a hard time understanding how they were working. Now, looking at these undocumented examples, I have an even harder time.

## Why?

In college I was very interested in programming languages. I had learned the usual C, Java, and Python, but kept googling for lesser known languages. My [professor](http://www.cse.scu.edu/~atkinson/) didn't mind if I used Icon (in fact he had studied under [Bill Griswold](https://cseweb.ucsd.edu/~wgg/), son of [Ralph Griswold](https://history.computer.org/pioneers/griswold.html), creator of Icon, and was well aware of it). It ended up being my secret weapon for completing assignments. It was the first language that I didn't feel I was fighting with when I thought of a design for a homework project. Its backtracking remains a compelling language feature and I hope to see it gain popularity again some day.

I decided I wanted my senior project to be a language, but I wasn't sure what to do. At the time POSIX threads were very intimidating so I started searching for alternate concurrency paradigms. MDC-90 wasn't as lost to memory as it is now. It added actors support to the C language. I read its documentation and decided to take its additions and add it to Icon.

I was a bit unprepared for this task. My college didn't have a compiler course, so I hacked together a parser that read one line at a time, sometimes looking ahead to the next line if necessary, that took the above code, translated it to raw Icon, and added on a runtime.

I also wrote four papers explaining it to my advisor. I've lost the LaTeX documents, but still have the `dvi` and `pdf` files. Reading through them now is a bit embarressing due to the quality of the writing and they come across rather sophomoric.

I am proud of what I implemented and after writing a lot of Erlang code fifteen years later, and developing a love for the actor model, I feel like I was a little ahead of the game after all.

## Miscellaneous

- The creator of MDC-90, [Thomas Christopher](https://www.tools-of-computing.com/tc/), was also a fan of Icon and wrote a [manual](https://www.tools-of-computing.com/tc/CS/iconprog.pdf) for it. I found this out after starting my project.
- I picked the name Crow because I was (and remain) a huge MST3K fan.
