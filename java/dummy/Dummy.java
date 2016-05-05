class Dummy {
  public static void main(String... args) {
    if (args.length == 0) {
      System.err.println("99 TSP - No input file");
      System.exit(1);
    }
    System.out.println("99 TSP - Input file is " + args[0] + ".tsp or .xml");
  }
}
