#define PROC_TABLE_SIZE 16


class scheduler { 

  public:
    scheduler();
    ~scheduler();

  private:
    struct {
      class proc *procs[PROC_TABLE_SIZE];
    } proc_table;

    //next proc to run
    class proc *next;

};
