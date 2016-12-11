import java.io.*;
import java.util.*;


public class TSP {
	
	public static final int SIZE = 280;
	public static final int NUM_ITER = 4000;
	public static final double TEMP = 20000;
	public static final double COOL_RATE = .9999;
	public static Random rand;
	
	public static void main(String[] args) {
		try {
			File input = new File(args[0]);
			Scanner scan = new Scanner(input);
			rand = new Random();
			ArrayList<Salesperson> salespeople = new ArrayList<Salesperson>();
			for (int i = 0; i < 6; i++) {
	            scan.nextLine();
	        }
			while(scan.hasNextInt()) {
				salespeople.add(new Salesperson(scan.nextInt(), scan.nextInt(), scan.nextInt()));
			}
			for(int i = 0; i < SIZE*2; i++) {
				salespeople = swapTours(salespeople);
			}
			ArrayList<Salesperson> copySalespeople = salespeople;
			ArrayList<Salesperson> minTour = salespeople;
			double minCost = tourCost(minTour);
			double temp = TEMP;
			for (int i = 0; i < NUM_ITER; i++) {
				ArrayList<Salesperson> newSalespeople = swapTours(copySalespeople);
				if (tourCost(newSalespeople) < tourCost(copySalespeople)) {
					copySalespeople = newSalespeople;
					if (tourCost(copySalespeople) < minCost) {
						minCost = tourCost(copySalespeople);
						minTour = copySalespeople;
					}
				} else if (coinFlipProbability(tourCost(copySalespeople), tourCost(newSalespeople), temp)) {
					copySalespeople = newSalespeople;
				}
				temp *= COOL_RATE;
			}
			System.out.println("Result cost is: " + minCost);
			
		} catch (Exception e) {
			System.out.println("Something went wrong here...");
		}
	}
	
	public static class Salesperson {
		int id;
		int xCoord;
		int yCoord;
		
		public Salesperson(int id, int xCoord, int yCoord) {
			this.id = id;
			this.xCoord = xCoord;
			this.yCoord = yCoord;
		}
	}
	
	public static boolean coinFlipProbability(double tour1, double tour2, double temp){
		  double flip = Math.exp(-1 * ((tour2-tour1)/temp));
		  double uniform = ((double) rand.nextDouble());
		  if (uniform < flip){
		    return true;
		  } else {
		    return false;
		  }
	}
	
	public static ArrayList<Salesperson> swapTours(ArrayList<Salesperson> salespeople){
		  ArrayList<Salesperson> newSalespeople = salespeople;
		  int p1, p2;
		  p1 = (int) rand.nextDouble() * salespeople.size();
		  p2 = (int) rand.nextDouble() * salespeople.size();
		  Collections.swap(newSalespeople, p1, p2);
		  return newSalespeople;
		}
	
	public static double tourCost(ArrayList<Salesperson> salespeople){
		  double cost = 0;
		  for (int i = 0; i < salespeople.size() - 1; i++){
			  double xDist = salespeople.get(i).xCoord - salespeople.get(i+1).xCoord;
			  double yDist = salespeople.get(i).yCoord - salespeople.get(i+1).yCoord;
			  cost += Math.sqrt(xDist * xDist + yDist * yDist);
		  }
		  double xDist = salespeople.get(salespeople.size()-1).xCoord - salespeople.get(0).xCoord;
		  double yDist = salespeople.get(salespeople.size()-1).yCoord - salespeople.get(0).yCoord;
		  cost += Math.sqrt(xDist * xDist + yDist * yDist);
		  return cost;    
		}

}
