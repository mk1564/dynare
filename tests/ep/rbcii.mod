@#define extended_path_version = 1

var Capital, Output, Labour, Consumption, Efficiency, efficiency, ExpectedTerm, LagrangeMultiplier;

varexo EfficiencyInnovation;

parameters beta, theta, tau, alpha, psi, delta, rho, effstar, sigma2;

/*
** Calibration
*/


beta    =  0.990;
theta   =  0.357;
tau     =  2.000;
alpha   =  0.450;
psi     =  -0.500;
delta   =  0.020;
rho     =  0.995;
effstar =  1.000;
sigma2  =  0.001;


@#if extended_path_version
    rho = 0.800;
@#endif
external_function(name=mean_preserving_spread);

model(block,bytecode,cutoff=0);

  // Eq. n°1:
  efficiency = rho*efficiency(-1) + EfficiencyInnovation;

  // Eq. n°2:
  Efficiency = effstar*exp(efficiency-mean_preserving_spread(rho));

  // Eq. n°3:
  Output = Efficiency*(alpha*(Capital(-1)^psi)+(1-alpha)*(Labour^psi))^(1/psi);

  // Eq. n°4:
  Capital = max(Output-Consumption + (1-delta)*Capital(-1),(1-delta)*Capital(-1));

  // Eq. n°5:
  ((1-theta)/theta)*(Consumption/(1-Labour)) - (1-alpha)*(Output/Labour)^(1-psi);

  // Eq. n°6:
  (((Consumption^theta)*((1-Labour)^(1-theta)))^(1-tau))/Consumption - LagrangeMultiplier  - ExpectedTerm(1);

  // Eq. n°7:
  (Capital==(1-delta)*Capital(-1))*(Output-Consumption) + (1-(Capital==(1-delta)*Capital(-1)))*LagrangeMultiplier = 0;
  
  // Eq. n°8:
  ExpectedTerm = beta*(((((Consumption^theta)*((1-Labour)^(1-theta)))^(1-tau))/Consumption)*(alpha*((Output/Capital(-1))^(1-psi))+(1-delta))-(1-delta)*LagrangeMultiplier);

end;




@#if extended_path_version

    shocks;
    var EfficiencyInnovation = sigma2;
    end;

    steady;
    
    options_.maxit_ = 100;
    options_.ep.verbosity = 0;
    options_.ep.stochastic = 0;
    options_.console_mode = 0;

    ts = extended_path([],100);

    plot(ts(2,:)-ts(4,:));

@#else

    shocks;
    var EfficiencyInnovation;
    periods 1;
    values -.4;
    end;

    steady;
    
    options_.maxit_ = 100;
    
    simul(periods=4000);

    n = 100;
    plot(Output(1:n)-Consumption(1:n),'-b','linewidth',2)
    
@#endif