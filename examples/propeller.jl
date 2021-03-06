using CCBlade
using PyPlot

# rotor definition
Rhub = 0.0254*.5
Rtip = 0.0254*3.0
B = 2  # number of blades
turbine = false

r = .0254*[0.7526, 0.7928, 0.8329, 0.8731, 0.9132, 0.9586, 1.0332,
     1.1128, 1.1925, 1.2722, 1.3519, 1.4316, 1.5114, 1.5911,
     1.6708, 1.7505, 1.8302, 1.9099, 1.9896, 2.0693, 2.1490, 2.2287,
     2.3084, 2.3881, 2.4678, 2.5475, 2.6273, 2.7070, 2.7867, 2.8661, 2.9410]
chord = .0254*[0.6270, 0.6255, 0.6231, 0.6199, 0.6165, 0.6125, 0.6054, 0.5973, 0.5887,
          0.5794, 0.5695, 0.5590, 0.5479, 0.5362, 0.5240, 0.5111, 0.4977,
          0.4836, 0.4689, 0.4537, 0.4379, 0.4214, 0.4044, 0.3867, 0.3685,
          0.3497, 0.3303, 0.3103, 0.2897, 0.2618, 0.1920]
theta = pi/180.0*[40.2273, 38.7657, 37.3913, 36.0981, 34.8803, 33.5899, 31.6400,
                   29.7730, 28.0952, 26.5833, 25.2155, 23.9736, 22.8421, 21.8075,
                   20.8586, 19.9855, 19.1800, 18.4347, 17.7434, 17.1005, 16.5013,
                   15.9417, 15.4179, 14.9266, 14.4650, 14.0306, 13.6210, 13.2343,
                   12.8685, 12.5233, 12.2138]

af = af_from_files("airfoils/NACA64_A17.dat")
airfoils = fill(af, length(r))

rotor = Rotor(Rhub, Rtip, B, turbine)
sections = Section.(r, chord, theta, airfoils)


rho = 1.225
Vinf = 10.0
Omega = 8000.0*pi/30.0

op = simple_op.(Vinf, Omega, r, rho)

outputs = solve.(Ref(rotor), sections, op)

figure()
plot(r/Rtip, outputs.Np)
plot(r/Rtip, outputs.Tp)
xlabel("r/Rtip")
ylabel("distributed loads (N/m)")
legend(["flapwise", "lead-lag"])

figure()
plot(r/Rtip, outputs.u/Vinf)
plot(r/Rtip, outputs.v/Vinf)
xlabel("r/Rtip")
ylabel("(normalized) induced velocity at rotor disk")
legend(["axial velocity", "swirl velocity"])

nJ = 20  # number of advance ratios

J = range(0.1, 0.9, length=nJ)  # advance ratio

Omega = 8000.0*pi/30
n = Omega/(2*pi)
D = 2*Rtip

eff = zeros(nJ)
CT = zeros(nJ)
CQ = zeros(nJ)

for i = 1:nJ
    Vinf = J[i] * D * n

    op = simple_op.(Vinf, Omega, r, rho)
    outputs = solve.(Ref(rotor), sections, op)
    T, Q = thrusttorque(rotor, sections, outputs)
    eff[i], CT[i], CQ[i] = nondim(T, Q, Vinf, Omega, rho, rotor)

end

figure()
plot(J, CT)
plot(J, CQ*2*pi)
xlabel(L"J")
legend([L"C_T", L"C_P"])

figure()
plot(J, eff)
xlabel(L"J")
ylabel(L"\eta")
