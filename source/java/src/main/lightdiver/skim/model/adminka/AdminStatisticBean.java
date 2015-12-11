package main.lightdiver.skim.model.adminka;

import main.lightdiver.skim.Users;
import main.lightdiver.skim.entity.UserEntity;
import main.lightdiver.skim.entity.UsersAction;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Created by Serj on 09.12.2015.
 */
@ManagedBean
@ViewScoped
public class AdminStatisticBean implements Serializable{
    private List<UsersAction> allUsersAction = null;
    private Date startDate;
    private Date endDate;
    private Integer userId = -1;
    private Integer successActionYes = -1;
    private List<SelectItem> usersList = null;

    @PostConstruct
    void Init(){
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_MONTH, 1);
        startDate = calendar.getTime();
        calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH));
        endDate = calendar.getTime();
        //System.out.println("startDate=" + startDate + " endDate="+endDate);
        List<UserEntity> uArrListU = Users.getUsersList();
        usersList = new ArrayList<>();
        for (int i = 0; i < uArrListU.size(); i++) {
            usersList.add(new SelectItem(uArrListU.get(i).getUserId(), uArrListU.get(i).getUserLogin()));
        }


    }

    public void loadListUsersAction(){
        allUsersAction = Users.getUsersAction(startDate, endDate, userId<=0?null:userId, successActionYes==-1?null:successActionYes);
        //System.out.println("successActionYes="+successActionYes);
    }

    public List<UsersAction> getAllUsersAction() {
        synchronized (this) {
            if (allUsersAction == null) {
                loadListUsersAction();
            }
            //System.out.println("Size allUsersAction:" + allUsersAction.size());
        }
        return allUsersAction;
    }

    public void setAllUsersAction(List<UsersAction> allUsersAction) {
        this.allUsersAction = allUsersAction;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getSuccessActionYes() {
        return successActionYes;
    }

    public void setSuccessActionYes(Integer successActionYes) {
        this.successActionYes = successActionYes;
    }

    public List<SelectItem> getUsersList() {
        return usersList;
    }

    public void setUsersList(List<SelectItem> usersList) {
        this.usersList = usersList;
    }
}
