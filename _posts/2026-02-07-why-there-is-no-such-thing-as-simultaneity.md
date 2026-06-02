---
layout: post
author: bela
image:
---

At the start of the 20th century Einstein discovered that two observers traveling at different speeds relative to eachother will observer events differently: clocks tick faster or slower, and objects contract/expand. This article goes over why this is the case and derrives a very simple formula that can be used to determine by how much time and space change the faster you travel.

Einstein began by coming up with two postulates for his framework
1. The laws of physics are the same in all inertial frames
2. The speed of light is constant for all observers regardless of their motion

From here he used simple thought experiments to theorize what would happen if two different observers traveled at different speeds to eachother, specifically at speeds close to the speed of light.

He discovered two fascinating properties: time passes at different rates for different observers, and the length of objects will contract/expand for different observers. These effects are not purely theoretical. Satelites (like the ones used for GPS navigation) need to take things like time-dilation into account to function properly!

## Time Dilation
Imagine two observers, one is "at rest" (stationary) on Earth and the other is in a rocket moving at a speed $v$ relative to the stationary observer. Each observer has their own reference frame, we will call the stationary reference frame $S'$, and the moving reference frame $S$.

![observers]({{ site.baseurl }}/assets/images/2026-02-07-why-there-is-no-such-thing-as-simultaneity/special-relativity-observers.png)

For this thought experiment we will bounce a photon between two mirrors (**photon clock**) place the photon clock perpendicular to the direction of travel of the space ship, i.e. if the space ships travels from left to right, the photon in the clock will bounce up and down. This way we know the direction of travel will not influence the distance between the two mirrors inside of the clock.

<div class="note-box" markdown="1">
**Photon Clock:** This is a device that measures time by bouncing a photon between two mirrors/surfaces. We know the distance between the two mirrors, we know the speed of time, so we can work out how much time has passed after each bounce completes.
</div>

The observers decide to start observations when the photon is at the top mirror, and then record the event where the photon reaches the bottom of the mirror.

* **The Moving Observer (Spaceship)** - The spaceship is traveling at a constant speed $v$, the austronauts on the spaceship are in zero gravity and feel weightless. When they look at the photon clock they see a photon moving up and down. They observe the photon traveling in a straight line from the top plate and note down that the photon reaches the bottom plate at time $t$. Nothing weird has happened.

* **The Station Observer (Earth)** - The scientists on Earth are observing the same photon clock inside of the spaceship. Relative to them, the mirrors of the photon clock are moving through space at constant speed $v$. As a result they observe the photon not traveling up and down in a straight path, but they see that the light is moving diagonally (it needs to cover both the vertical distance between the two mirrors, and the horizontal distance that the bottom mirror has moved). They note down that the photon reaches the bottom plate at a time $t'$


When the astronauts on the spaceship compare their notes to the scientists on earth they cannot agree on how long it took for the photon to reach the bottom plate. The astronauts say it took a $t$ seconds, the scientists disagree and say it took a much longer $t'$ seconds.

The reason the two observers disagree is because depending on the frame of reference the photon had to travel a different distance. From the stationary observers point of view the photon had to travel a lot further. Einstein's second postulate dictates that the speed of light remains constant at a value $c$, which means it takes longer for the photon to reach the bottom mirror.

What this means is that the same events take longer for the stationary observer compared to the moving observer. I.e. time moves faster for stationary observers, and passes more quickly for moving observers. 

<!-- * From the perspective of the **moving** observer (spaceship), the photon reached the bottom mirror at a time $t$. Relative to the space ship the mirrors have not moved during this time.
* From the perspective of the **stationary** observer (earth), the photon reached the bottom mirror at a time $t'$. Relative to the earth the mirrors have moved a distance $vt'$ by the time the photon has reached the bottom mirror. -->

![observers]({{ site.baseurl }}/assets/images/2026-02-07-why-there-is-no-such-thing-as-simultaneity/time-dilation.png)

From the spaceships point of view nothing weird has happened, the photon has simply bounced between two plates. From the earth's point of view the mirrors have moved along with the spaceship, so the photons have traveled a longer (diagonal) distance while completing the same bounce.

The important thing to remember is that the speed of light $c$ is the same for all observers. Speed is a measure of distance over time. If the speed of the photon *must* remain constant, and the distance the photon has traveled has increased (from the stationary observer's point of view), then the time for this event to occur (from the stationary observer's point of view) must have slowed down. So if you are the stationary observer, compared to you, time passes slower on the space ship. If you are the moving observer, compared to you, time passes faster down on earth.

The extra distance traveled in the stationary observers reference frame can be calculated using Pythagorean theorum.

$$
(ct)^2+(vt')^2=(ct')^2
$$

This can be used to relate the time it took for the event to take place from the stationary observer's point of view $t'$  to the time for the event to take place from the moving observer's point of view $t$

$$
t'^2 = \frac{c^2t^2}{c^2-v^2}
$$

$$
t'^2 = \frac{t^2}{1-v^2/c^2}
$$

$$
t' = \sqrt{\frac{t^2}{1-v^2/c^2}}
$$

From this it follows that the time dilation can be represented by a
factor of $\gamma$

$$
\boxed{t'=\gamma t}
$$

$$
\boxed{\gamma = \frac{1}{\sqrt{1-v^2/c^2}}}
$$

## Length Contraction
Imagine two observers, one is at rest in a space station and the other is in a rocket moving at a speed $v$ relative to the stationary observer. This time the photon clock is oriented in the direction of the path of travel of the moving observer.

* The **moving** observer will have recorded the photon going back and forth covering a distance $2ct$
* The **stationary** observer will record the photon going back and forth however the surface will have moved causing an increase in distance on the first leg of the the photon's trip and a shorter distance on the second leg of the photon's trip

![](./attachments/length_contraction.png)


The distances can be calculated in terms of the original distance $L$
$$ct_1'=L+vt_1'$$
$$ct_2'=L-vt_2'$$
From the distances expressions for the times can be obtained
$$t_1'=\frac{L}{c-v}$$
$$t_2' = \frac{L}{c+v}$$
These terms can be used to determine the total time taken for a single back-and-forth of the photon

$$t'=t_1'+t_2'$$
$$t' = \frac{L}{c-v}+\frac{L}{c-v}$$
$$t' = L(\frac{c+v}{c^2-v^2}+\frac{c-v}{c^2-v^2})$$
$$t' = \frac{2cL}{c^2-v^2}$$
$$t' = \frac{2L}{c}\frac{1}{1-v^2/c^2}$$
$$t'=\gamma^2\frac{2L}{c}$$
$$t'=\gamma^2\frac{2L}{c}$$$$t=\frac{2L_0}{c}$$

$$t'=\gamma t$$
$$\gamma^2 \frac{2L}{c} = \gamma \frac{2L_0}{c}$$
$$L=\frac{L_0}{\gamma}$$
