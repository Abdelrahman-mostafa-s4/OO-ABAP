# SAP ABAP - Object-Oriented Programming (OOP) Concepts

A comprehensive guide to ABAP OOP: Classes, Inheritance, Interfaces, Exception Handling, Events, Persistence Classes, ALV (via `CL_SALV_TABLE`), and the Singleton design pattern.

---

## 1) Types of Classes

### Global Class
- Created using transaction code: `SE24`
- Types:
  - **Usual ABAP Class** → Used to write business logic (similar to a Function Module).
  - **Exception Class** → Used to raise and handle exceptions.
  - **Persistence Class** → Used to perform database operations (Insert, Update, Delete).
  - **Unit Test Class** → Used to write unit test cases.

### Local Class
- Dedicated to a single program only.
- Created with the help of transaction code: `SE38`
- `CLASS DEFINITION`: Declaration only (no logic is written here — only the definitions).
- `CLASS IMPLEMENTATION`: Contains the actual logic.

```abap
CLASS MY_CLASS_NAME DEFINITION.
  PUBLIC SECTION.
    METHODS MY_METHOD_NAME IMPORTING PVBELN TYPE VBELN_VA
                            EXPORTING PPOSNR TYPE POSNR_VA
                                      PMATNR TYPE MATNR.
ENDCLASS.
```

**How to distinguish an Instance Method from a Static Method:**
- `METHODS` → defines an Instance Method.
- `CLASS-METHODS` → defines a Static Method.

---

## 2) Levels of Methods

| Type | Description |
|---|---|
| Instance Method | An object must be created in order to call the method |
| Static Method | No object is required to call the method |

---

## 3) Visibility Control

| Visibility | Access Scope |
|---|---|
| **Public** | Accessible within the class, within subclasses, and outside the class |
| **Private** | Accessible only within the class |
| **Protected** | Accessible within the class and subclasses, but not outside |

---

## 4) Importing / Exporting / Changing / Returning

- **Importing** → Input
- **Exporting** → Output
- **Changing** → Can act as both input and output
- **Returning** → Allows only a single returning parameter

> From the **METHOD**'s point of view: the value coming in is `IMPORTING`, and the value going out is `EXPORTING`.
> From the **PROGRAM**'s point of view: the program passes a value to the method, so that value is `EXPORTING` from the program's side; the method then returns a value to the program, so that value is `IMPORTING` from the program's side.

---

## 5) Object

An **Object** is an instance of a class.

> Note: A `SELECT-OPTION` is internally an Internal Table.

---

## 6) Inheritance

Inheritance is the process of creating a subclass from a parent class. It allows new classes to be derived from existing ones. The logic is written inside the parent class's methods, and once inherited, the subclass does not need to rewrite that logic.

### Final Class
A class that cannot be inherited — it cannot have any subclasses.

### Abstract Class
- A special type of class that contains at least one abstract method.
- An abstract method has only a definition — it has no implementation.
- An object cannot be created directly from an abstract class.
- Objects can be created from subclasses of an abstract class.
- The class itself must not be `FINAL`, and the abstract method must not contain any code.
- When the abstract class is inherited by another class, the method must be **redefined** in order to write its implementation.

---

## 7) Polymorphism

Polymorphism means being able to assign different behavior to something that was originally declared in a parent class, depending on the subclass. For example, a method can be declared in a parent class, while each subclass provides its own implementation of that method.

### Method Overriding
1. Occurs between two classes that have an inheritance relationship (a superclass and a subclass).
2. In method overriding, both methods must have the same name and the same signature.

---

## 8) Interface

- All methods in an interface are **public** by default.
- All methods in an interface are **abstract** by default (definition only, no implementation).
- When using an interface, only the method signature is defined — there is no source code. When implementing it in a class, there is no need to redefine it; the logic can be written directly.

```abap
INTERFACE MY_INTERFACE.
  METHODS: DISPLAY IMPORTING P_VBELN
                    EXPORTING P_ERNAM.
ENDINTERFACE.

CLASS SALES DEFINITION.
  PUBLIC SECTION.
    INTERFACES MY_INTERFACE.
ENDCLASS.

CLASS SALES IMPLEMENTATION.
  METHOD MY_INTERFACE~DISPLAY.
    SELECT SINGLE ernam, erzet, erdat
      FROM VBAK
      INTO (@P_ERNAM)
      WHERE VBELN = @P_VBELN.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA: LO TYPE REF TO SALES.
  CREATE OBJECT LO.

  LO->MY_INTERFACE~DISPLAY(
    EXPORTING
      P_VBELN = V_VBELN
    IMPORTING
      P_ERNAM = V_ERNAM
  ).

  WRITE: / V_ERNAM.
```

### Difference Between an Abstract Class and an Interface

| Abstract Class | Interface |
|---|---|
| Has at least one abstract method; the rest can be non-abstract | All methods are abstract |
| Method visibility can be Public, Private, or Protected | All methods are public |
| The abstract method must be redefined in subclasses to provide an implementation | No need to redefine (the Redefine button is disabled); the logic can be written directly via double-click |
| A static method cannot be redefined | Multiple inheritance is possible |
| Multiple inheritance is not possible | — |

---

## 9) Events

Events allow a method in one class to trigger a method in another class.

- **Triggering Method**: The method that raises the event.
- **Event Handler Method**: The method that handles the event.
- The event handler method is registered using the `SET HANDLER` statement.

> If something raises an event, it must be handled. The method that raises the event is called the Triggering Method. Whenever the event is raised, it must be handled by the Event Handler Method. The final step is to register the event handler method using `SET HANDLER`.

```abap
SET HANDLER object_2->message FOR object_1.
```

This statement acts as the "coordinator" linking `OBJECT_1` and `OBJECT_2`, even though neither object has any direct knowledge of the other. It registers with the ABAP Runtime that whenever `OBJECT_1` executes:

```abap
RAISE EVENT where_input.
```

the Runtime must call:

```abap
object_2->message( ).
```

### Who Actually Raises the Event, and Why?

Consider the following:

```abap
DATA lo_grid TYPE REF TO cl_gui_alv_grid.
CREATE OBJECT lo_grid
  EXPORTING
    i_parent = lo_object.
```

Here, an object of class `CL_GUI_ALV_GRID` is created. This object is what is actually displayed to the user on the screen.

Then:

```abap
METHOD double_click_handler
  FOR EVENT double_click OF cl_gui_alv_grid.
```

This declaration means: "This method is capable of handling an event called `DOUBLE_CLICK` raised by any object of type `CL_GUI_ALV_GRID`" — without specifying which exact object.

When the user double-clicks on the ALV, they are actually double-clicking on the ALV Grid object itself (`lo_grid`). Since `lo_grid` is of type `CL_GUI_ALV_GRID`, it owns the `DOUBLE_CLICK` event. The ABAP Runtime is responsible for raising the event, and it knows which method to call through the line:

```abap
SET HANDLER event->double_click_handler FOR lo_grid.
```

**Real-world analogy:**
- `lo_grid` = the receptionist (the one who receives the interaction and triggers the event).
- `double_click_handler` = the instructions executed after hearing the bell.
- `VBELN` = the order number the receptionist took.
- `lo_grid_2` = the place where the goods are displayed after being retrieved.

The bell rings not because of the order number, but because the customer pressed it at the receptionist's desk. The order number is simply the data used afterward inside the event handler.

---

## 10) The ME Keyword

It is possible to have a variable declared within a method that shares the same name as one of the class's attributes. To clearly distinguish between the two, the `ME` keyword is used.

- To print the value at the method level, simply reference the variable directly.
- To print the value at the class level, you must write `ME->`.

```abap
CLASS CLASS1 DEFINITION.
  PUBLIC SECTION.
    DATA: V_VALUE TYPE N VALUE 7.
    METHODS: DISPLAY.
ENDCLASS.

CLASS CLASS1 IMPLEMENTATION.
  METHOD DISPLAY.
    DATA: V_VALUE TYPE N VALUE 5.
    WRITE: / 'Value at method level: ', V_VALUE.
    WRITE: / 'Value at class level: ', ME->V_VALUE.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA: LO TYPE REF TO CLASS1.
  CREATE OBJECT LO.
  LO->DISPLAY( ).
```

---

## 11) Constructor

1. A constructor is a special type of method that executes automatically whenever an object is created.
2. It cannot be called using the `CALL METHOD` statement.
3. Constructors have a predefined, fixed name.
4. A class cannot contain more than one `CONSTRUCTOR` or more than one `CLASS_CONSTRUCTOR`.

### Types of Constructors

| CONSTRUCTOR (Instance) | CLASS_CONSTRUCTOR (Static) |
|---|---|
| Method name: `CONSTRUCTOR` | Method name: `CLASS_CONSTRUCTOR` |
| Has only Importing parameters | Has no parameters at all |
| Can access both static and instance attributes | Can access only static attributes |
| Called every time an object is created | Called only once, the first time an object is created |

> When an object is created for the first time, the static constructor is called first, followed by the instance constructor.

**Difference between an attribute and a local parameter:**
- `mv_vbeln` is an attribute belonging to the object, so it can be accessed by any method within the class.
- `iv_vbeln` is a local parameter specific to the constructor, and it ceases to exist once the constructor finishes execution.

> The class is the blueprint, while the object is the actual entity that holds the data. The constructor receives data and stores it inside the object via its attributes.

---

## 12) PBO / PAI (Screen Processing)

- **PBO (Process Before Output)**: Executed before the screen is displayed, in order to prepare and populate its content.
- **PAI (Process After Input)**: Executed after the user interacts with the screen, to process commands such as Back, Save, or button presses.
- **Screen Cycle**: `PBO` → screen is displayed → user interacts → `PAI` → `PBO` again.
- **Double-click in ALV**: This is an ALV-specific event and does not pass through PAI.
- **SET HANDLER**: Links an ALV event to the method that should execute when it occurs.
- `e_row-index`: Holds the row number the user clicked on within the ALV.
- `READ TABLE ... INDEX e_row-index`: Retrieves the data of the clicked row from the internal table.
- `WA_HEADER-VBELN`: Holds the sales order number corresponding to the row selected by the user.
- **SELECT from VBAP**: Retrieves the item data belonging only to the selected VBELN.
- `CALL SCREEN 0200`: Navigates the user to the second screen after the data has been prepared.
- `CREATE OBJECT`: Used to create the container and the ALV only once.
- `set_table_for_first_display()`: Links the ALV to the internal table and the field catalog for the first display.
- `refresh_table_display()`: Instructs the ALV to re-read the internal table and display the updated data.
- `IF lo_grid IS INITIAL`: Prevents the ALV from being created more than once.
- The container and the ALV are not recreated every time — they are created once and then reused.
- **Field Catalog**: Defines the properties, names, and order of the ALV columns.
- **Business Logic**: Operations such as SELECT and UPDATE belong in an event or in PAI, depending on the interaction method.
- **UI Logic**: Operations such as creating or refreshing the ALV belong in PBO.
- **Button on the screen**: Pressing it goes to PAI via `sy-ucomm`.
- **Event in ALV**: Such as Double Click or Hotspot — it calls the event handler directly without passing through PAI.

### Example: Double-Click Flow

```
lo_grid (Header ALV)
   |
   | Double Click
   V
double_click_handler
   |
   | SELECT from VBAP
   V
it_item
   |
   V
CALL SCREEN 0200
   |
   V
lo_grid_2 displays the data
```

> Note that `lo_grid_2` is not the one that raised the event — it is simply the result after the event has been processed.

```abap
SET HANDLER event->double_click_handler FOR lo_grid_2.
```

This means: "When the user double-clicks on the second ALV." This can only happen after Screen 0200 has been opened and the second ALV has actually been displayed.

---

## 13) ALV via CL_SALV_TABLE (ALV Object Model)

1. `CL_SALV_TABLE` is part of the ALV Object Model.
2. The ALV Object Model is an encapsulation of the pre-existing ALV tools into a single unit.
3. For example, `CL_SALV_TABLE` combines `CL_GUI_ALV_GRID` for container-based display, as well as `REUSE_ALV_GRID_DISPLAY` and `REUSE_ALV_LIST_DISPLAY` for full-screen display.

```
ALV OBJECT MODEL

CL_SALV_TABLE            CL_SALV_HIERSEQ_TABLE          CL_SALV_TREE
CL_GUI_ALV_GRID          REUSE_ALV_HIERSEQ_LIST_DISPLAY
REUSE_ALV_GRID_DISPLAY
REUSE_ALV_LIST_DISPLAY
```

- **Advantage of the ALV Object Model**: It provides a single, unified interface to all ALV tools.
- **Disadvantage of the ALV Object Model**: It does not support editable ALV grids.

### Factory Method

Rather than returning the object itself, it returns an object reference variable. With `CL_SALV_TABLE`, you do not write `CREATE OBJECT` directly, because object creation is handled internally by the factory method.

```abap
DATA: lo_alv TYPE REF TO cl_salv_table.

cl_salv_table=>factory(
  IMPORTING
    r_salv_table = lo_alv
  CHANGING
    t_table      = it_vbak
).

lo_alv->display( ).
```

- `CL_SALV_TABLE` ← Class
- `FACTORY` ← A static method within the class
- `lo_alv` ← Object reference; the actual object is created internally within the factory method.

**Purpose of the Factory Method**: To provide an instance (object) of a given class without the caller needing to use `CREATE OBJECT` directly.

### Function Settings
`CL_SALV_TABLE` contains the method `IF_SALV_GUI_OM_TABLE_INFO~GET_FILTERS`, which only retrieves a function object. An object of the matching return type must first be declared, after which `SET_ALL` or `SET_DEFAULT` can be called from `CL_SALV_FUNCTIONS_LIST`.

### Column Settings
`CL_SALV_TABLE` contains the method `IF_SALV_GUI_OM_TABLE_INFO~GET_COLUMNS`, which retrieves a column object. An object of the matching return type must be declared, after which you can call:
- `SET_COLUMN_POSITION` from `CL_SALV_COLUMNS_TABLE` to change a column's position.
- `GET_COLUMN` from `CL_SALV_COLUMNS_TABLE` to retrieve a single column.
- `SET_LONG_TEXT` from `CL_SALV_COLUMN`.

> In other words, to change the text of a specific column, you access the class `CL_SALV_COLUMNS_TABLE` and use the method `GET_COLUMN`, which has two parameters: `COLUMNNAME` and `VALUE`. The `VALUE` parameter is `TYPE REF TO`, meaning it returns an object, so a matching object must be declared. That class is `CL_SALV_COLUMN`, which contains the method `SET_LONG_TEXT`.

### Sorting
First, retrieve the object needed to perform sorting:
- `IF_SALV_GUI_OM_TABLE_INFO~GET_SORTS` from `CL_SALV_TABLE` returns an object reference. Declare an object of type `TYPE REF TO CL_SALV_SORTS`.
- This class contains the method `ADD_SORT`, which has the parameters: `COLUMNNAME`, `POSITION`, `SEQUENCE`, `SUBTOTAL`, `GROUP`, `OBLIGATORY`.
- The `VALUE` returned by `ADD_SORT` is an object reference representing a single sort operation. Declare an object of type `TYPE REF TO CL_SALV_SORT`.
- The class `CL_SALV_SORT` contains the method `SET_SEQUENCE`, which is responsible for setting the sort direction (ascending/descending).
- Finally, when `DISPLAY` is called, the ALV is shown sorted according to the defined settings.

### Filtering
First, retrieve the object needed to perform filtering:
- `IF_SALV_GUI_OM_TABLE_INFO~GET_FILTERS` from `CL_SALV_TABLE` returns an object reference. Declare an object of type `TYPE REF TO CL_SALV_FILTERS`.
- This class contains the method `ADD_FILTER`, which has the parameters: `COLUMNNAME`, `SIGN`, `OPTION`, `LOW`, `HIGH`.
- The `VALUE` returned by `ADD_FILTER` is an object of type `CL_SALV_FILTER` (not always required, since the filter is applied as soon as it is created).
- Finally, when `DISPLAY` is called, the ALV is shown with the filter already applied.

> `CL_SALV_FILTER` contains the method `ADD_SELOPT`, which is used to add an additional condition to an already existing filter. In other words, if you want to add another condition to a filter you have already created, you should not use `ADD_FILTER` again — instead, retrieve the object reference from the class `CL_SALV_FILTERS` and use `ADD_SELOPT`.

### PF-Status, User-Command, and Get_Selected_Rows

**Concept:** A button is added to the PF-STATUS. When the user presses it, the selected row is identified, its VBELN is retrieved, and the corresponding items from table VBAP are displayed.

**Steps:**

1. **Create the PF-STATUS:**
   ```abap
   SET PF-STATUS 'MYSTATUS'.
   ```
   Then link it to the SALV object using `SET_SCREEN_STATUS`.

2. **Detect that the user pressed the button:**
   The SALV object has an event called `ADDED_FUNCTION`, found within `CL_SALV_EVENTS_TABLE`. The event object is retrieved using `GET_EVENT`, and the handler is linked to the event using `SET HANDLER`.
   ```
   User presses the button → ADDED_FUNCTION → USER_COMMAND
   ```

3. **Identify the row selected by the user:**
   Although `CL_SALV_TABLE` is used, the method needed to retrieve the selected rows belongs to `CL_GUI_ALV_GRID`. Therefore, `GET_GLOBALS_FROM_SLVC_FULLSCR` is used to obtain a reference to the internal grid (`CL_GUI_ALV_GRID`), followed by `GET_SELECTED_ROWS` to determine the selected row number.

4. **Retrieve the VBELN:**
   After identifying the selected row number, the same row is read from `IT_HEADER` using `READ TABLE`, which provides `WA_HEADER-VBELN` — the sales order selected by the user.

5. **Fetch the items:**
   Using the retrieved VBELN, a `SELECT` is performed against `VBAP` to fetch the related items into `IT_ITEM`.

6. **Display the items:**
   A new SALV instance is created using `CL_SALV_TABLE=>FACTORY`, and `IT_ITEM` is then displayed.

```
PF-STATUS → ADDED_FUNCTION → USER_COMMAND → GET_GLOBALS_FROM_SLVC_FULLSCR
→ CL_GUI_ALV_GRID → GET_SELECTED_ROWS → Identify the selected row
→ Read the VBELN from IT_HEADER → SELECT from VBAP → IT_ITEM
→ Display the items in a new SALV instance
```

---

## 14) Persistence Class

A Persistence Class does not mean that SELECT and SQL statements are entirely replaced by OOP — rather, it provides a way to work with database data as objects.

- Its purpose is to perform database operations such as Insert, Update, and Delete.
- The class name must always start with `CL`.
- When the class is activated, SAP automatically generates two helper classes: **CA** and **CB**.
  - **CA** → Actor Class (also known as the Agent Class).
  - **CB** → Base Class.

```
SAP Persistence Framework
      ↓
Creates/provides an Agent Object
      ↓
The AGENT attribute holds a reference to it
      ↓
This reference is stored in LO_AGENT
```

**Difference between a regular object and a persistent object:**

```
LO_GRID_1 → [Object of CL_GUI_ALV_GRID]
I hold a reference → I created the object myself → the reference points to that object

SELECT / UPDATE / DELETE → I interact directly with the database

Persistence Class → I represent database data as an object
The object has data, methods, and behavior
The object is linked to persistent data
This allows me to build business logic around the object
```

**GET_PERSISTENT:**

```
P_VBELN = 100
   ↓
GET_PERSISTENT
   ↓
Does an object representing VBELN = 100 exist?
   ↓
┌─────────┴─────────┐
↓                   ↓
Exists             Does not exist
↓                   ↓
Reference          Exception
↓             CX_OS_OBJECT_NOT_FOUND
LO_OBJECT
```

```abap
IF LO_OBJECT IS NOT INITIAL.
  MESSAGE ...
ENDIF.
```

> If `LO_OBJECT` holds a reference, this means an object already exists for that VBELN — meaning the number already exists and should not be created again.

---

## 15) Exception Class

- An **exception** is a problem that arises during the execution of a program.
- The purpose of an exception class is to raise and handle exceptions.
- A `TRY` block is used to raise an exception, and a `CATCH` block is used to handle it.
- The exception class name must always start with `CX`.
- `CX_ROOT` is the global (parent) class for all exceptions.

### The 3 Subclasses of CX_ROOT

1. `CX_STATIC_CHECK`
2. `CX_DYNAMIC_CHECK`
3. `CX_NO_CHECK`

### CX_STATIC_CHECK

The compiler checks the code before runtime to verify that it follows correct syntax rules, and also checks whether proper exception handling has been implemented. If not, the compiler blocks activation with a message similar to:

> ⚠️ Warning! This method may raise an exception, and you have not implemented handling for it.

In short, `CX_STATIC_CHECK` forces the compiler to ensure that exception handling has been accounted for, after which the actual handling is implemented using `TRY...CATCH`.

> Note: When creating an exception class, the system provides `CX_STATIC_CHECK` as the default superclass.

### Ways to Create an Exception Class
1. An exception class with messages from a message class.
2. An exception class without messages from a message class.

### Who Handles the Exception?

The answer is: the object.

```abap
DATA: lo_exception TYPE REF TO z_order.
CATCH z_order INTO lo_exception.
```

Whatever exception is raised is passed into the object.

---

## 16) Singleton Class

A Singleton class is a class that ensures only a single instance/object of it is ever created throughout the entire program execution.

Normally, objects are created using `CREATE OBJECT` or `NEW`, and any number of instances can be created. However, in many cases only a single instance of a class is required throughout the whole execution — this is where a Singleton class is used.

- An instance/object cannot be created from outside the class.
- The logic for creating the instance/object is written inside the class itself.
- This means the singleton class itself controls the creation of its own instance/object.

### Core Components of a Singleton

**CONSTRUCTOR**
- Visibility: `Private`
- Purpose: Prevents any code outside the class from directly using `CREATE OBJECT`.

**Static Attribute** (e.g., `LO_OBJECT`)
- Visibility: `Private`
- Purpose: Stores the single instance and persists at the class level for the entire program's runtime.

**Static Method** (e.g., `GET_INSTANCE`)
- Visibility: `Public`
- Purpose: The only entry point allowed for accessing the object.

### Why Must LO_OBJECT Be Static Rather Than Local?
- **Local variable**: Is cleared every time the method finishes execution, so every call would create a new object — breaking the singleton pattern.
- **Static attribute**: Remains stored in memory across different calls, so it is created only on the first call, and every subsequent call returns the same instance.

### Why Must LO_OBJECT Be Private Rather Than Public?
So that no code outside the class can directly modify or clear it, which would otherwise break the singleton guarantee.

### Logic Inside GET_INSTANCE

```abap
METHOD GET_INSTANCE.
  IF LO_OBJECT IS INITIAL.      " First call: TRUE
    CREATE OBJECT LO_OBJECT.    " Created only once
  ENDIF.
  RO_OBJECT = LO_OBJECT.        " Returns the same reference every time
ENDMETHOD.
```

As a result, any two variables (e.g., `lo_x`, `lo_y`) that call `GET_INSTANCE` will reference the exact same object:

```abap
IF lo_x = lo_y.
  WRITE: 'Same object'.
ENDIF.
```

### Lazy vs. Eager Initialization

| Lazy (`IF IS INITIAL`) | Eager (`CLASS_CONSTRUCTOR`) |
|---|---|
| The object is created only when it is actually needed | The object is created automatically the first time the program references the class, even if it is never used |
| Best suited when object creation is heavy or slow (e.g., selecting from a large table) | Best suited when the operation is simple, fast, and guaranteed to be used |

### Additional Concept: Race Condition
In multi-threaded environments (not common in traditional ABAP), two threads could check `IS INITIAL` at the same moment before either has created the object, resulting in two objects being created instead of one. This is typically resolved using synchronization mechanisms (outside the scope of traditional ABAP).

> **Static Attribute**: A single variable shared across the entire class (not tied to a specific object), and it remains stored in memory for the entire duration of the program session — even after the method that modified it has finished executing. It can be accessed from anywhere, at any time, throughout the program's execution, provided it is declared as `PUBLIC`.
